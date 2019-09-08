object FrameWelcome: TFrameWelcome
  Left = 0
  Top = 0
  Width = 320
  Height = 177
  TabOrder = 0
  object Panel1: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 314
    Height = 86
    Align = alTop
    Caption = ' '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object lbAppName: TLabel
      AlignWithMargins = True
      Left = 4
      Top = 6
      Width = 306
      Height = 40
      Margins.Top = 5
      Align = alTop
      Alignment = taCenter
      Caption = 'lbAppName'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -33
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ExplicitWidth = 166
    end
    object lbAppVersion: TLabel
      AlignWithMargins = True
      Left = 4
      Top = 52
      Width = 306
      Height = 16
      Align = alTop
      Alignment = taCenter
      Caption = 'lbAppVersion'
      ExplicitWidth = 75
    end
    object Bevel1: TBevel
      AlignWithMargins = True
      Left = 4
      Top = 76
      Width = 306
      Height = 3
      Margins.Top = 5
      Align = alTop
      Shape = bsTopLine
      ExplicitTop = 74
    end
  end
  object tmrFrameReady: TTimer
    Interval = 1
    OnTimer = tmrFrameReadyTimer
    Left = 40
    Top = 32
  end
end
