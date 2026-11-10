object FrmInformes: TFrmInformes
  Left = 240
  Top = 130
  BorderStyle = bsDialog
  Caption = 'Informe de ventas'
  ClientHeight = 480
  ClientWidth = 700
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlFiltros: TPanel
    Left = 0
    Top = 0
    Width = 700
    Height = 73
    Align = alTop
    TabOrder = 0
    object lblDesde: TLabel
      Left = 8
      Top = 14
      Width = 31
      Height = 13
      Caption = 'Desde'
    end
    object lblHasta: TLabel
      Left = 152
      Top = 14
      Width = 28
      Height = 13
      Caption = 'Hasta'
    end
    object lblClienteFiltro: TLabel
      Left = 8
      Top = 44
      Width = 32
      Height = 13
      Caption = 'Cliente'
    end
    object edtDesde: TEdit
      Left = 48
      Top = 10
      Width = 81
      Height = 21
      TabOrder = 0
    end
    object edtHasta: TEdit
      Left = 192
      Top = 10
      Width = 81
      Height = 21
      TabOrder = 1
    end
    object edtCliente: TEdit
      Left = 48
      Top = 40
      Width = 225
      Height = 21
      TabOrder = 2
    end
    object chkSoloConfirmados: TCheckBox
      Left = 296
      Top = 12
      Width = 121
      Height = 17
      Caption = 'Solo confirmados'
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
    object btnGenerar: TButton
      Left = 440
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Generar'
      TabOrder = 4
      OnClick = btnGenerarClick
    end
    object btnExportar: TButton
      Left = 520
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Exportar'
      TabOrder = 5
      OnClick = btnExportarClick
    end
  end
  object grdInforme: TDBGrid
    Left = 0
    Top = 73
    Width = 700
    Height = 320
    Align = alTop
    DataSource = dsInforme
    TabOrder = 1
  end
  object pnlResumen: TPanel
    Left = 0
    Top = 393
    Width = 700
    Height = 87
    Align = alClient
    TabOrder = 2
    object lblCantidad: TLabel
      Left = 8
      Top = 12
      Width = 3
      Height = 13
    end
    object lblTotalNeto: TLabel
      Left = 200
      Top = 12
      Width = 3
      Height = 13
    end
    object lblTotalIva: TLabel
      Left = 200
      Top = 32
      Width = 3
      Height = 13
    end
    object lblTotalGeneral: TLabel
      Left = 200
      Top = 52
      Width = 3
      Height = 13
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnCerrar: TButton
      Left = 616
      Top = 48
      Width = 75
      Height = 25
      Caption = 'Cerrar'
      TabOrder = 0
      OnClick = btnCerrarClick
    end
  end
  object qryInforme: TDBISAMQuery
    DatabaseName = 'PEDIDOS'
    EngineVersion = '4.24 Build 1'
    Left = 616
    Top = 104
  end
  object dsInforme: TDataSource
    DataSet = qryInforme
    Left = 648
    Top = 104
  end
end
