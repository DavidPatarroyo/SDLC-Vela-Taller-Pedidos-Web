program PedidosLegado;

uses
  Forms,
  UDMPrincipal in 'src\UDMPrincipal.pas' {DMPrincipal: TDataModule},
  UGlobales in 'src\UGlobales.pas',
  UUtilidades in 'src\UUtilidades.pas',
  UCalculoTotales in 'src\UCalculoTotales.pas',
  UStock in 'src\UStock.pas',
  UFrmPrincipal in 'src\UFrmPrincipal.pas' {FrmPrincipal},
  UFrmClientes in 'src\UFrmClientes.pas' {FrmClientes},
  UFrmProductos in 'src\UFrmProductos.pas' {FrmProductos},
  UFrmPedidos in 'src\UFrmPedidos.pas' {FrmPedidos},
  UFrmInformes in 'src\UFrmInformes.pas' {FrmInformes};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Pedidos Distribuidora';
  Application.CreateForm(TDMPrincipal, DMPrincipal);
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.
