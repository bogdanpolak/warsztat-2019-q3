object FrameImport: TFrameImport
  Left = 0
  Top = 0
  Width = 320
  Height = 240
  TabOrder = 0
  object tmrFrameReady: TTimer
    Interval = 1
    OnTimer = tmrFrameReadyTimer
    Left = 32
    Top = 8
  end
end
