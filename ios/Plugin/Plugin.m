#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(CameraPreview, "CameraPreview",
           CAP_PLUGIN_METHOD(requestPermission, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(prepare, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(start, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(listenForOtherEvents, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(show, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(hide, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(stop, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(capture, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(flip, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(getSupportedFlashModes, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(setFlashMode, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(listenOnVolumeButton, CAPPluginReturnCallback);
)
