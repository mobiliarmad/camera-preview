export type CallbackID = string;

export type CameraPosition = "rear" | "front";
export interface CameraPreviewOptions {
  /** Parent element to attach the video preview element to (applicable to the web platform only) */
  parent?: string;
  /** Class name to add to the video preview element (applicable to the web platform only) */
  className?: string;
  /** The preview width in pixels, default window.screen.width (applicable to the android and ios platforms only) */
  width?: number;
  /** The preview height in pixels, default window.screen.height (applicable to the android and ios platforms only) */
  height?: number;
  /** The x origin, default 0 (applicable to the android and ios platforms only) */
  x?: number;
  /** The y origin, default 0 (applicable to the android and ios platforms only) */
  y?: number;
  /** The x origin for primary landscape, default 0 (applicable to the android and ios platforms only) */
  primaryX?: number;
  /** The x origin for secondary landscape, default 0 (applicable to the android and ios platforms only) */
  secondaryX?: number;
  /** Brings your html in front of your preview, default false (applicable to the android only) */
  toBack?: boolean;
  /** The preview bottom padding in pixes. Useful to keep the appropriate preview sizes when orientation changes (applicable to the android and ios platforms only) */
  paddingBottom?: number;
  /** Rotate preview when orientation changes (applicable to the ios platforms only; default value is true) */
  rotateWhenOrientationChanged?: boolean;
  /** Choose the camera to use 'front' or 'rear', default 'front' */
  position?: CameraPosition | string;
  /** Defaults to false - Capture images to a file and return back the file path instead of returning base64 encoded data */
  storeToFile?: boolean;
  /** Defaults to false - Android Only - Disable automatic rotation of the image, and let the browser deal with it (keep reading on how to achieve it) */
  disableExifHeaderStripping?: boolean;
  /** Defaults to false - iOS only - Activate high resolution image capture so that output images are from the highest resolution possible on the device **/
  enableHighResolution?: boolean;
  /** Defaults to false - Web only - Disables audio stream to prevent permission requests and output switching */
  disableAudio?: boolean;
  /** The picture quality, 0 - 100, default 85 */
  quality?: number;
  /** The thumbnail picture width, default 0 (don't use thumbnail) */
  thumbnailWidth?: number;
}

export type CameraPreviewFlashMode =
  | "off"
  | "on"
  | "auto"
  | "red-eye"
  | "torch";

export interface ImageResult {
  image: string;
  thumbnailImage?: string;
}
export interface VolumeButtonResult {
  volumeButtonChanged: boolean;
}

export type VolumeButtonCallback = (
  data: VolumeButtonResult | null,
  err?: any
) => void;
export interface CameraPreviewPlugin {
  requestPermission(): Promise<void>;
  prepare(options: CameraPreviewOptions): Promise<{}>;
  start(): Promise<{}>;
  show(): Promise<{}>;
  hide(): Promise<{}>;
  stop(): Promise<{}>;
  capture(): Promise<ImageResult>;
  getSupportedFlashModes(): Promise<{
    result: CameraPreviewFlashMode[];
  }>;
  setFlashMode(options: { flashMode: CameraPreviewFlashMode | string }): void;
  flip(): void;
  listenOnVolumeButton(callback: VolumeButtonCallback): Promise<CallbackID>;
}
