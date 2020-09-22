package cn.rongcloud.chatroomdemo.http;

import android.text.TextUtils;
import cn.rongcloud.rtc.base.RTCErrorCode;
import io.rong.common.RLog;
import java.io.BufferedReader;
import java.io.Closeable;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.SocketTimeoutException;
import java.net.URL;
import java.util.Iterator;
import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;

public class HttpHelper {
    public int CONNECT_TIME_OUT = 8 * 1000;
    private static final String TAG = "HttpClient";
    private boolean mEnableSelfCertificate; //是否启用自签名

    private HttpHelper() {}

    private static class SingletonHolder {

        static HttpHelper sDefaultHttpClient = new HttpHelper();
    }

    private static class SingletonHolderExecutorService {

        static ExecutorService executorService = Executors.newCachedThreadPool();
    }

    public static HttpHelper getDefault() {
        return SingletonHolder.sDefaultHttpClient;
    }

    public boolean isEnableSelfCertificate() {
        return mEnableSelfCertificate;
    }

    public void setEnableSelfCertificate(boolean enableSelfCertificate) {
        mEnableSelfCertificate = enableSelfCertificate;
    }

    public void request(final Request request, final ResultCallback callback) {
        executorService()
                .execute(
                        new Runnable() {
                            @Override
                            public void run() {
                                doRequest(
                                        request,
                                        new ResultCallback() {
                                            @Override
                                            public void onResponse(String result) {
                                                if (callback != null) {
                                                    callback.onResponse(result);
                                                }
                                            }

                                            @Override
                                            public void onFailure(int errorCode) {
                                                if (callback != null) {
                                                    callback.onFailure(errorCode);
                                                }
                                            }
                                        });
                            }
                        });
    }

    private void doRequest(Request request, ResultCallback callback) {
        HttpURLConnection urlConnection = null;
        InputStream inputStream = null;
        InputStreamReader inputStreamReader = null;
        BufferedReader bufferedReader = null;
        try {
            String header = request.getRequestHeaders();
            urlConnection = createConnection(request);
            urlConnection.connect();
            int responseCode = urlConnection.getResponseCode();
            if (responseCode != HttpURLConnection.HTTP_OK) {
                InputStream is = urlConnection.getErrorStream();
                if (is != null) {
                    byte[] bytes = new byte[is.available()];
                    is.read(bytes);
                    String error = new String(bytes, "utf-8");
                    closeStream(is);
                }
                urlConnection.disconnect();
                //ReportUtil.libError(ReportUtil.TAG.HTTP_REQUEST, "url|header", request.url(), request.getHeaders());
                callback.onFailure(responseCode);
                return;
            }

            inputStream = urlConnection.getInputStream();
            inputStreamReader = new InputStreamReader(inputStream);
            bufferedReader = new BufferedReader(inputStreamReader);
            StringBuilder result = new StringBuilder();
            String line;
            while ((line = bufferedReader.readLine()) != null) {
                result.append(line);
            }
            callback.onResponse(result.toString());
        } catch (SocketTimeoutException timeout) {
            //ReportUtil.libError(ReportUtil.TAG.HTTP_REQUEST, "url|header", request.url(), request.getHeaders());
            callback.onFailure(RTCErrorCode.RongRTCCodeHttpTimeoutError.getValue());
        } catch (Exception e) {
            //ReportUtil.libError(ReportUtil.TAG.HTTP_REQUEST, "url|header", request.url(), request.getHeaders());
            callback.onFailure(RTCErrorCode.RongRTCCodeHttpResponseError.getValue());
        } finally {
            closeStream(inputStream);
            closeStream(inputStreamReader);
            closeStream(bufferedReader);
            if (urlConnection != null) {
                urlConnection.disconnect();
            }
        }
    }

    private static ExecutorService executorService() {
        return SingletonHolderExecutorService.executorService;
    }

    public interface ResultCallback {
        void onResponse(String result);

        void onFailure(int errorCode);
    }

    private void closeStream(Closeable stream) {
        try {
            if (stream != null) {
                stream.close();
            }
        } catch (IOException e) {
            RLog.e(TAG, "closeStream exception ", e);
        }
    }

    private HttpURLConnection createConnection(Request request) throws IOException {
        URL url;
        HttpURLConnection conn;
        RLog.i(TAG, "request url : " + request.url());
        final String host = getNavHost(request.url());
        if (request.url().toLowerCase().startsWith("https")) {
            url = new URL(request.url());
            if (mEnableSelfCertificate) {
                SSLContext sslContext = SelfSSLUtils.getSSLContext();
                HttpsURLConnection c = (HttpsURLConnection) url.openConnection();
                c.setSSLSocketFactory(sslContext.getSocketFactory());
                c.setHostnameVerifier(new SelfSSLUtils.TrustAnyHostnameVerifier());
                conn = c;
            } else {
                conn = (HttpsURLConnection) url.openConnection();
                ((HttpsURLConnection) conn)
                        .setHostnameVerifier(
                                new HostnameVerifier() {
                                    @Override
                                    public boolean verify(String hostname, SSLSession session) {
                                        return !TextUtils.isEmpty(host) && host.contains(hostname);
                                    }
                                });
            }
        } else {
            url = new URL(request.url());
            conn = (HttpURLConnection) url.openConnection();
        }
        conn.setRequestMethod(request.method());
        conn.setConnectTimeout(CONNECT_TIME_OUT);
        conn.setReadTimeout(CONNECT_TIME_OUT);
        conn.setUseCaches(false);

        if (!TextUtils.isEmpty(host)) {
            conn.setRequestProperty("Host", host);
        }

        conn.setRequestProperty("Accept", "application/json;charset=UTF-8");
        conn.setRequestProperty("Content-Type", "application/json;charset=UTF-8");
        conn.setRequestProperty("Connection", "Keep-Alive");
        if (request.getHeaders() != null && request.getHeaders().getHeaders() != null) {
            Set<String> setKey = request.getHeaders().getHeaders().keySet();
            Iterator<String> iterator = setKey.iterator();
            while (iterator.hasNext()) {
                String key = iterator.next();
                String value = request.getHeaders().getHeaders().get(key);
                conn.setRequestProperty(key, value);
            }
        }

        conn.setDoInput(true);
        if (TextUtils.equals(request.method(), RequestMethod.POST)) {
            conn.setDoOutput(true);
            String body = request.body();
            if (body == null) {
                throw new NullPointerException("Request.body == null");
            }
            OutputStream outputStream = conn.getOutputStream();
            PrintWriter printWriter = new PrintWriter(outputStream);
            printWriter.write(request.body());
            printWriter.flush();
        }
        return conn;
    }

    private static String getNavHost(String navi) {
        try {
            URL url = new URL(navi);
            String host = url.getHost();
            int port = url.getPort();
            if (port != -1 && (url.getDefaultPort() != url.getPort())) {
                host = host + ":" + port;
            }
            return host;
        } catch (MalformedURLException e) {
            RLog.e(TAG, "MalformedURLException ", e);
        }
        return null;
    }
}
