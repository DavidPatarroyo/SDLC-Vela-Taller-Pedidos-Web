object FrmClientes: TFrmClientes
  Left = 230
  Top = 140
  BorderStyle = bsSingle
  Caption = 'Clientes'
  ClientHeight = 450
  ClientWidth = 640
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
  object pnlBuscar: TPanel
    Left = 0
    Top = 0
    Width = 640
    Height = 41
    Align = alTop
    TabOrder = 0
    object lblBuscar: TLabel
      Left = 8
      Top = 14
      Width = 36
      Height = 13
      Caption = 'Buscar:'
    end
    object edtBuscar: TEdit
      Left = 56
      Top = 10
      Width = 249
      Height = 21
      TabOrder = 0
    end
    object btnBuscar: TButton
      Left = 312
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Buscar'
      TabOrder = 1
      OnClick = btnBuscarClick
    end
  end
  object grdClientes: TDBGrid
    Left = 0
    Top = 41
    Width = 640
    Height = 200
    Align = alTop
    DataSource = dsCli
    TabOrder = 1
  end
  object pnlDatos: TPanel
    Left = 0
    Top = 241
    Width = 640
    Height = 209
    Align = alClient
    TabOrder = 2
    object lblRut: TLabel
      Left = 16
      Top = 16
      Width = 23
      Height = 13
      Caption = 'RUT'
    end
    object lblRazon: TLabel
      Left = 16
      Top = 44
      Width = 63
      Height = 13
      Caption = 'Razon social'
    end
    object lblTipo: TLabel
      Left = 16
      Top = 72
      Width = 64
      Height = 13
      Caption = 'Tipo (N / V)'
    end
    object lblRegion: TLabel
      Left = 16
      Top = 100
      Width = 34
      Height = 13
      Caption = 'Region'
    end
    object lblDireccion: TLabel
      Left = 16
      Top = 128
      Width = 45
      Height = 13
      Caption = 'Direccion'
    end
    object lblTelefono: TLabel
      Left = 16
      Top = 156
      Width = 42
      Height = 13
      Caption = 'Telefono'
    end
    object dbeRut: TDBEdit
      Left = 104
      Top = 12
      Width = 121
      Height = 21
      DataField = 'RUT'
      DataSource = dsCli
      TabOrder = 0
    end
    object dbeRazon: TDBEdit
      Left = 104
      Top = 40
      Width = 300
      Height = 21
      DataField = 'RAZON_SOCIAL'
      DataSource = dsCli
      TabOrder = 1
    end
    object dbeTipo: TDBEdit
      Left = 104
      Top = 68
      Width = 33
      Height = 21
      DataField = 'TIPO'
      DataSource = dsCli
      TabOrder = 2
    end
    object dbeRegion: TDBEdit
      Left = 104
      Top = 96
      Width = 49
      Height = 21
      DataField = 'REGION'
      DataSource = dsCli
      TabOrder = 3
    end
    object dbeDireccion: TDBEdit
      Left = 104
      Top = 124
      Width = 300
      Height = 21
      DataField = 'DIRECCION'
      DataSource = dsCli
      TabOrder = 4
    end
    object dbeTelefono: TDBEdit
      Left = 104
      Top = 152
      Width = 145
      Height = 21
      DataField = 'TELEFONO'
      DataSource = dsCli
      TabOrder = 5
    end
    object btnNuevo: TButton
      Left = 456
      Top = 12
      Width = 75
      Height = 25
      Caption = 'Nuevo'
      TabOrder = 6
      OnClick = btnNuevoClick
    end
    object btnGrabar: TButton
      Left = 456
      Top = 44
      Width = 75
      Height = 25
      Caption = 'Grabar'
      TabOrder = 7
      OnClick = btnGrabarClick
    end
    object btnEliminar: TButton
      Left = 456
      Top = 76
      Width = 75
      Height = 25
      Caption = 'Eliminar'
      TabOrder = 8
      OnClick = btnEliminarClick
    end
    object btnCerrar: TButton
      Left = 456
      Top = 164
      Width = 75
      Height = 25
      Caption = 'Cerrar'
      TabOrder = 9
      OnClick = btnCerrarClick
    end
  end
  object tblCli: TDBISAMTable
    BeforePost = tblCliBeforePost
    DatabaseName = 'PEDIDOS'
    EngineVersion = '4.24 Build 1'
    TableName = 'CLIENTES'
    Left = 568
    Top = 8
  end
  object dsCli: TDataSource
    DataSet = tblCli
    Left = 600
    Top = 8
  end
end
