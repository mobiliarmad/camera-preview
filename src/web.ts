import { WebPlugin } from "@capacitor/core";
import {
  CameraPreviewOptions,
  CameraPreviewPlugin,
  CameraPreviewFlashMode,
  CallbackID,
  ImageResultCallback,
} from "./definitions";

export class CameraPreviewWeb extends WebPlugin implements CameraPreviewPlugin {
  constructor() {
    super({
      name: "CameraPreview",
      platforms: ["web"],
    });
  }

  prepare(_options: CameraPreviewOptions): Promise<{}> {
    throw new Error("Method not implemented.");
  }

  show(): Promise<{}> {
    throw new Error("Method not implemented.");
  }
  hide(): Promise<{}> {
    throw new Error("Method not implemented.");
  }

  requestPermission(): Promise<void> {
    throw new Error("Method not implemented.");
  }

  start(_callback: ImageResultCallback): Promise<CallbackID> {
    throw new Error("Method not implemented.");
  }

  stop(): Promise<any> {
    throw new Error("Method not implemented.");
  }

  capture(): Promise<any> {
    throw new Error("Method not implemented.");
  }

  getSupportedFlashModes(): Promise<{
    result: CameraPreviewFlashMode[];
  }> {
    throw new Error("Method not implemented.");
  }

  setFlashMode(_options: {
    flashMode: CameraPreviewFlashMode | string;
  }): Promise<void> {
    throw new Error("setFlashMode not supported under the web platform");
  }

  flip(): Promise<void> {
    throw new Error("flip not supported under the web platform");
  }
}
