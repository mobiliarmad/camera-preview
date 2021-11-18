import { WebPlugin } from "@capacitor/core";
import {
  CameraPreviewOptions,
  CameraPreviewPlugin,
  CameraPreviewFlashMode,
  VolumeButtonCallback,
  CallbackID,
} from "./definitions";

export class CameraPreviewWeb extends WebPlugin implements CameraPreviewPlugin {
  constructor() {
    super({
      name: "CameraPreview",
      platforms: ["web"],
    });
  }

  listenForOtherEvents(): Promise<{}> {
    throw new Error("Method not implemented.");
  }

  listenOnVolumeButton(_callback: VolumeButtonCallback): Promise<CallbackID> {
    throw new Error("Method not implemented.");
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

  start(): Promise<any> {
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
