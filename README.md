# Capacitor Camera Preview Of Hanuman

Capacitor plugin that allows camera interaction from Javascript and HTML (based on cordova-plugin-camera-preview)
This plugin support iOS only.


# Installation

```
npm install @capacitor-mobi/camera-preview
```

Then run

```
npx cap update
```

# Features

-Support create a thumbnail image together with the original image.

-Use CoreMotion to detect the orientation when use lock to portrait mode.

-Play audio like a native camera when clicking on the take picture button.

-Tap to focus.

-Pinch to zoom.

-Support zoom out for the rear camera. ("builtInDualWideCamera": one ultra wide and one wide angle)

-Listen on volume button to take image.

-Show flash screen animation when taking picture.

-Support the camera frame rotate to landscape left or landscape right. 


# Methods

### prepare(options)

Prepare the camera preview instance.
(Not showing camera preview on UI yet)
<br>

| Option                       | values        | descriptions                                                                                                                                                             |
| ---------------------------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| position                     | front \| rear | Show front or rear camera when start the preview. Defaults to front                                                                                                      |
| width                        | number        | (optional) The preview width in pixels, default window.screen.width (applicable to the android and ios platforms only)                                                   |
| height                       | number        | (optional) The preview height in pixels, default window.screen.height (applicable to the android and ios platforms only)                                                 |
| x                            | number        | (optional) The x origin, default 0 (applicable to the android and ios platforms only)                                                                                    |
| y                            | number        | (optional) The y origin, default 0 (applicable to the android and ios platforms only)                                                                                    |
| toBack                       | boolean       | (optional) Brings your html in front of your preview, default false (applicable to the android and ios platforms only)                                                   |
| paddingBottom                | number        | (optional) The preview bottom padding in pixes. Useful to keep the appropriate preview sizes when orientation changes (applicable to the android and ios platforms only) |
| rotateWhenOrientationChanged | boolean       | (optional) Rotate preview when orientation changes (applicable to the ios platforms only; default value is true)                                                         |
| storeToFile                  | boolean       | (optional) Capture images to a file and return back the file path instead of returning base64 encoded data, default false.                                               |
| disableExifHeaderStripping   | boolean       | (optional) Disable automatic rotation of the image, and let the browser deal with it, default true (applicable to the android and ios platforms only)                    |
| disableAudio                 | boolean       | (optional) Disables audio stream to prevent permission requests, default false. (applicable to web only)                                                                 |
| quality        | number | (optional) The picture quality, 0 - 100, default 85                     |
| thumbnailWidth | number | (optional) The thumbnail picture width, default 0 (don't use thumbnail) |

```javascript
import { Plugins } from "@capacitor/core";
const { CameraPreview } = Plugins;
import { CameraPreviewOptions } from "@capacitor-community/camera-preview";

const cameraPreviewOptions: CameraPreviewOptions = {
  position: "rear",
  height: 1920,
  width: 1080,
  quality: 50,
  thumbnailWidth: 200,
  
  // Support camera frame rotate to landscape left or landscape right
  primaryX: cameraHeaderHeight,
  secondaryX: cameraFooterHeight
};
CameraPreview.prepare(cameraPreviewOptions);
```

Remember to add the style below on your app's HTML or body element:

```css
ion-content {
  --background: transparent;
}
```

Take into account that this will make transparent all ion-content on application, if you want to show camera preview only in one page, just add a cutom class to your ion-content and make it transparent:

```css
.my-custom-camera-preview-content {
  --background: transparent;
}
```

### start()

Show the camera preview after the preparation is done.

```javascript
CameraPreview.start();
```

### hide()

Hide the camera preview but not destroy it. 
(Useful when your want to show it immediately)

```javascript
CameraPreview.hide();
```

### show()

Show the camera preview immediately.

```javascript
CameraPreview.show();
```

### stop()

Stops the camera preview instance.
(After it stops, we need to call the "prepare" and "start" as the beginning)

```javascript
CameraPreview.stop();
```

### flip()

<info>Switch between rear and front camera </info>

```javascript
CameraPreview.flip();
```

### capture()

```javascript
import { CameraPreviewFlashMode } from "@capacitor-community/camera-preview";

const result = await CameraPreview.capture();
// If "storeToFile = true", the result.image will be the file path.
// If "storeToFile = false", the result.image will be the Base64 string.
const imagePath = result.image;
const thumbnailPath = result.thumbnailImage as string;
```

### listenOnVolumeButton()

Listen on volume button (up or down)

```javascript
CameraPreview.listenOnVolumeButton(async (res: VolumeButtonResult | null) => {
	if (!res || !res.volumeButtonChanged) {
		return;
	}
	// Call your capture function
});
```

### getSupportedFlashModes()

<info>Get the flash modes supported by the camera device currently started. Returns an array containing supported flash modes. See <code>[FLASH_MODE](#camera_Settings.FlashMode)</code> for possible values that can be returned</info><br/>

```javascript
import { CameraPreviewFlashMode } from "@capacitor-community/camera-preview";

const flashModes = await CameraPreview.getSupportedFlashModes();
const supportedFlashModes: CameraPreviewFlashMode[] = flashModes.result;
```

### setFlashMode(options)

<info>Set the flash mode. See <code>[FLASH_MODE](#camera_Settings.FlashMode)</code> for details about the possible values for flashMode.</info><br/>

```javascript
const CameraPreviewFlashMode: CameraPreviewFlashMode = "torch";

CameraPreview.setFlashMode(cameraPreviewFlashMode);
```

# Settings

<a name="camera_Settings.FlashMode"></a>

### FLASH_MODE

<info>Flash mode settings:</info><br/>

| Name    | Type   | Default | Note         |
| ------- | ------ | ------- | ------------ |
| OFF     | string | off     |              |
| ON      | string | on      |              |
| AUTO    | string | auto    |              |
| RED_EYE | string | red-eye | Android Only |
| TORCH   | string | torch   |              |
