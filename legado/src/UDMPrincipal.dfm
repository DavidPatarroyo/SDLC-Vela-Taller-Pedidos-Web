object DMPrincipal: TDMPrincipal
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Left = 285
  Top = 161
  Height = 320
  Width = 420
  object dbPedidos: TDBISAMDatabase
    EngineVersion = '4.24 Build 1'
    DatabaseName = 'PEDIDOS'
    Directory = 'C:\PEDIDOS\DATOS'
    KeepConnection = True
    SessionName = 'Default'
    Left = 40
    Top = 16
  end
  object tblClientes: TDBISAMTable
    DatabaseName = 'PEDIDOS'
    EngineVersion = '4.24 Build 1'
    TableName = 'CLIENTES'
    Left = 40
    Top = 72
  end
  object tblProductos: TDBISAMTable
    DatabaseName = 'PEDIDOS'
    EngineVersion = '4.24 Build 1'
    TableName = 'PRODUCTOS'
    Left = 128
    Top = 72
  end
  object tblPedidos: TDBISAMTable
    DatabaseName = 'PEDIDOS'
    EngineVersion = '4.24 Build 1'
    TableName = 'PEDIDOS'
    Left = 216
    Top = 72
  end
  object tblLineas: TDBISAMTable
    DatabaseName = 'PEDIDOS'
    EngineVersion = '4.24 Build 1'
    TableName = 'PEDIDO_LINEAS'
    Left = 304
    Top = 72
  end
  object tblParametros: TDBISAMTable
    DatabaseName = 'PEDIDOS'
    EngineVersion = '4.24 Build 1'
    TableName = 'PARAMETROS'
    Left = 40
    Top = 128
  end
  object qryGeneral: TDBISAMQuery
    DatabaseName = 'PEDIDOS'
    EngineVersion = '4.24 Build 1'
    Left = 40
    Top = 192
  end
  object qryAux: TDBISAMQuery
    DatabaseName = 'PEDIDOS'
    EngineVersion = '4.24 Build 1'
    Left = 128
    Top = 192
  end
end
