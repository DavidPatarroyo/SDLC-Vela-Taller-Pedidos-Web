object FrmProductos: TFrmProductos
  Left = 250
  Top = 150
  BorderStyle = bsSingle
  Caption = 'Productos'
  ClientHeight = 420
  ClientWidth = 680
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlFiltro: TPanel
    Left = 0
    Top = 0
    Width = 680
    Height = 41
    Align = alTop
    TabOrder = 0
    object lblFiltro: TLabel
      Left = 8
      Top = 14
      Width = 57
      Height = 13
      Caption = 'Descripcion'
    end
    object edtFiltro: TEdit
      Left = 72
      Top = 10
      Width = 233
      Height = 21
      TabOrder = 0
    end
    object btnFiltrar: TButton
      Left = 312
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Filtrar'
      TabOrder = 1
      OnClick = btnFiltrarClick
    end
    object chkBajoMinimo: TCheckBox
      Left = 400
      Top = 12
      Width = 137
      Height = 17
      Caption = 'Solo bajo stock minimo'
      TabOrder = 2
    end
  end
  object grdProductos: TDBGrid
    Left = 0
    Top = 41
    Width = 680
    Height = 320
    Align = alTop
    DataSource = dsProd
    TabOrder = 1
  end
  object navProductos: TDBNavigator
    Left = 8
    Top = 376
    Width = 240
    Height = 25
    DataSource = dsProd
    TabOrder = 2
  end
  object btnCerrar: TButton
    Left = 592
    Top = 376
    Width = 75
    Height = 25
    Caption = 'Cerrar'
    TabOrder = 3
    OnClick = btnCerrarClick
  end
  object tblProd: TDBISAMTable
    BeforePost = tblProdBeforePost
    DatabaseName = 'PEDIDOS'
    EngineVersion = '4.24 Build 1'
    TableName = 'PRODUCTOS'
    Left = 600
    Top = 8
  end
  object dsProd: TDataSource
    DataSet = tblProd
    Left = 632
    Top = 8
  end
end
