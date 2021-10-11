object Form1: TForm1
  Left = 225
  Top = 126
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Labirint Generation'
  ClientHeight = 627
  ClientWidth = 840
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object Laby: TImage
    Left = 8
    Top = 8
    Width = 825
    Height = 577
  end
  object BtGo: TButton
    Left = 8
    Top = 595
    Width = 169
    Height = 25
    Caption = 'Generation'
    TabOrder = 0
    OnClick = BtGoClick
  end
  object BtChemin: TButton
    Left = 184
    Top = 595
    Width = 121
    Height = 25
    Caption = 'Path'
    TabOrder = 1
    OnClick = BtCheminClick
  end
end
