object FrmPedidos: TFrmPedidos
  Left = 210
  Top = 120
  BorderStyle = bsSingle
  Caption = 'Toma de pedidos'
  ClientHeight = 520
  ClientWidth = 720
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
  object pnlCliente: TPanel
    Left = 0
    Top = 0
    Width = 720
    Height = 65
    Align = alTop
    TabOrder = 0
    object lblRut: TLabel
      Left = 8
      Top = 14
      Width = 56
      Height = 13
      Caption = 'RUT cliente'
    end
    object lblCliente: TLabel
      Left = 300
      Top = 14
      Width = 3
      Height = 13
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblTipo: TLabel
      Left = 300
      Top = 38
      Width = 3
      Height = 13
    end
    object lblRegion: TLabel
      Left = 480
      Top = 38
      Width = 3
      Height = 13
    end
    object edtRutCliente: TEdit
      Left = 72
      Top = 10
      Width = 121
      Height = 21
      TabOrder = 0
    end
    object btnBuscarCliente: TButton
      Left = 200
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Buscar'
      TabOrder = 1
      OnClick = btnBuscarClienteClick
    end
  end
  object pnlLineas: TPanel
    Left = 0
    Top = 65
    Width = 720
    Height = 41
    Align = alTop
    TabOrder = 1
    object lblCodigo: TLabel
      Left = 8
      Top = 14
      Width = 33
      Height = 13
      Caption = 'Codigo'
    end
    object lblCantidad: TLabel
      Left = 168
      Top = 14
      Width = 42
      Height = 13
      Caption = 'Cantidad'
    end
    object edtCodProducto: TEdit
      Left = 48
      Top = 10
      Width = 105
      Height = 21
      TabOrder = 0
    end
    object edtCantidad: TEdit
      Left = 216
      Top = 10
      Width = 57
      Height = 21
      TabOrder = 1
    end
    object btnAgregar: TButton
      Left = 288
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Agregar'
      TabOrder = 2
      OnClick = btnAgregarClick
    end
    object btnQuitar: TButton
      Left = 368
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Quitar'
      TabOrder = 3
      OnClick = btnQuitarClick
    end
  end
  object sgLineas: TStringGrid
    Left = 0
    Top = 106
    Width = 720
    Height = 250
    Align = alTop
    ColCount = 5
    DefaultRowHeight = 18
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
    TabOrder = 2
    ColWidths = (
      80
      300
      80
      110
      120)
  end
  object pnlTotales: TPanel
    Left = 0
    Top = 356
    Width = 720
    Height = 164
    Align = alClient
    TabOrder = 3
    object lblSubtotal: TLabel
      Left = 480
      Top = 12
      Width = 3
      Height = 13
    end
    object lblDescuento: TLabel
      Left = 480
      Top = 32
      Width = 3
      Height = 13
    end
    object lblFlete: TLabel
      Left = 480
      Top = 52
      Width = 3
      Height = 13
    end
    object lblIva: TLabel
      Left = 480
      Top = 72
      Width = 3
      Height = 13
    end
    object lblTotal: TLabel
      Left = 480
      Top = 96
      Width = 3
      Height = 16
      Font.Height = -13
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblObs: TLabel
      Left = 8
      Top = 12
      Width = 71
      Height = 13
      Caption = 'Observaciones'
    end
    object memObs: TMemo
      Left = 8
      Top = 28
      Width = 433
      Height = 81
      TabOrder = 0
    end
    object btnGrabar: TButton
      Left = 8
      Top = 124
      Width = 89
      Height = 25
      Caption = 'Grabar pedido'
      TabOrder = 1
      OnClick = btnGrabarClick
    end
    object btnNuevo: TButton
      Left = 104
      Top = 124
      Width = 75
      Height = 25
      Caption = 'Nuevo'
      TabOrder = 2
      OnClick = btnNuevoClick
    end
    object btnCerrar: TButton
      Left = 632
      Top = 124
      Width = 75
      Height = 25
      Caption = 'Cerrar'
      TabOrder = 3
      OnClick = btnCerrarClick
    end
  end
end
