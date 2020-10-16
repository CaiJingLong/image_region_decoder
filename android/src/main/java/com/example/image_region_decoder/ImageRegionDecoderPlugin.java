package com.example.image_region_decoder;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.BitmapRegionDecoder;
import android.graphics.Rect;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * ImageRegionDecoderPlugin
 */
@SuppressWarnings("rawtypes")
public class ImageRegionDecoderPlugin implements FlutterPlugin, MethodCallHandler {
    private static final Handler handler = new Handler(Looper.getMainLooper());

    private static final ExecutorService threadPool = Executors.newFixedThreadPool(5);

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "image_region_decoder");
        channel.setMethodCallHandler(this);
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "image_region_decoder");
        channel.setMethodCallHandler(new ImageRegionDecoderPlugin());
    }

    @Override
    public void onMethodCall(@NonNull final MethodCall call, @NonNull final Result result) {
        if (call.method.equals("imageRect")) {
            threadPool.execute(new Runnable() {
                @Override
                public void run() {
                    byte[] image = call.argument("image");
                    Map rectMap = call.argument("rect");
                    assert rectMap != null;
                    Rect rect = toRect(rectMap);
                    final Bitmap bitmap = getBitmapWithRect(image, rect);
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            if (bitmap == null) {
                                replyError(result, "Cannot convert image");
                            } else {
                                handleBitmap(call, result, bitmap);
                            }
                        }
                    });

                }
            });
        } else {
            result.notImplemented();
        }
    }

    private void replyError(final Result result, String errorMsg) {
        result.error(errorMsg, null, null);
    }

    private void handleBitmap(@NonNull final MethodCall call, @NonNull final Result result, @NonNull Bitmap bitmap) {
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, outputStream);
        byte[] bytes = outputStream.toByteArray();
        result.success(bytes);
        bitmap.recycle();
    }

    private Bitmap getBitmapWithRect(byte[] image, Rect rect) {
        ByteArrayInputStream inputStream = new ByteArrayInputStream(image);
        try {
            BitmapRegionDecoder regionDecoder = BitmapRegionDecoder.newInstance(inputStream, true);
            BitmapFactory.Options options = new BitmapFactory.Options();
            return regionDecoder.decodeRegion(rect, options);
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        } finally {
            try {
                inputStream.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    public Rect toRect(Map map) {
        int left = (int) (double) map.get("l");
        int top = (int) (double) map.get("t");
        int width = (int) (double) map.get("w");
        int height = (int) (double) map.get("h");
        return new Rect(left, top, left + width, top + height);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
