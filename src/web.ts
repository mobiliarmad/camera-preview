import { WebPlugin } from "@capacitor/core";
import {
  CameraPreviewOptions,
  CameraPreviewPictureOptions,
  CameraPreviewPlugin,
  CameraPreviewFlashMode,
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

  start(): Promise<{}> {
    throw new Error("Method not implemented.");
  }

  stop(): Promise<any> {
    throw new Error("Method not implemented.");
  }

  capture(_options: CameraPreviewPictureOptions): Promise<any> {
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
