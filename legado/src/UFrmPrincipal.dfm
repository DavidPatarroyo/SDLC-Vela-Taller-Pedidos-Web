object FrmPrincipal: TFrmPrincipal
  Left = 192
  Top = 107
  Width = 800
  Height = 600
  Caption = 'Pedidos - Distribuidora'
  Color = clAppWorkSpace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsNormal
  Menu = mnuPrincipal
  OldCreateOrder = False
  Position = poScreenCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object sbEstado: TStatusBar
    Left = 0
    Top = 535
    Width = 792
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object mnuPrincipal: TMainMenu
    Left = 24
    Top = 16
    object mnuArchivo: TMenuItem
      Caption = '&Archivo'
      object mnuSalir: TMenuItem
        Caption = '&Salir'
        OnClick = mnuSalirClick
      end
    end
    object mnuMaestros: TMenuItem
      Caption = '&Maestros'
      object mnuClientes: TMenuItem
        Caption = '&Clientes'
        OnClick = mnuClientesClick
      end
      object mnuProductos: TMenuItem
        Caption = '&Productos'
        OnClick = mnuProductosClick
      end
    end
    object mnuVentas: TMenuItem
      Caption = '&Ventas'
      object mnuPedidos: TMenuItem
        Caption = '&Toma de pedidos'
        OnClick = mnuPedidosClick
      end
      object mnuInformes: TMenuItem
        Caption = '&Informe de ventas'
        OnClick = mnuInformesClick
      end
    end
  end
end
