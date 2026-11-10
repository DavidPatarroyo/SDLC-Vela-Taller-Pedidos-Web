unit UFrmPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ComCtrls;

type
  TFrmPrincipal = class(TForm)
    mnuPrincipal: TMainMenu;
    mnuArchivo: TMenuItem;
    mnuSalir: TMenuItem;
    mnuMaestros: TMenuItem;
    mnuClientes: TMenuItem;
    mnuProductos: TMenuItem;
    mnuVentas: TMenuItem;
    mnuPedidos: TMenuItem;
    mnuInformes: TMenuItem;
    sbEstado: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure mnuSalirClick(Sender: TObject);
    procedure mnuClientesClick(Sender: TObject);
    procedure mnuProductosClick(Sender: TObject);
    procedure mnuPedidosClick(Sender: TObject);
    procedure mnuInformesClick(Sender: TObject);
  private
    procedure CargarParametros;
  public
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

uses
  UDMPrincipal, UGlobales, UFrmClientes, UFrmProductos, UFrmPedidos,
  UFrmInformes;

{$R *.dfm}

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  InicializarGlobales;
  gUsuario := UpperCase(Trim(InputBox('Pedidos', 'Usuario:', '')));
  if gUsuario = '' then
    gUsuario := 'VENTAS';
  if (gUsuario = 'ADMIN') or (gUsuario = 'JEFEVENTAS') then
    gNivelUsuario := 9;
  DMPrincipal.Conectar;
  CargarParametros;
  gFechaSistema := Date;
  sbEstado.SimpleText := 'Usuario: ' + gUsuario + '   Version ' + VERSION_SISTEMA;
end;

{ lee la tabla de parametros }
procedure TFrmPrincipal.CargarParametros;
var
  vValor: string;
begin
  vValor := DMPrincipal.LeerParametro('TASA_IVA');
  if vValor <> '' then
    gTasaIVA := StrToFloat(vValor) / 100;
  vValor := DMPrincipal.LeerParametro('IMPRESORA');
  if vValor <> '' then
    gImpresora := vValor;
end;

procedure TFrmPrincipal.mnuSalirClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmPrincipal.mnuClientesClick(Sender: TObject);
begin
  FrmClientes := TFrmClientes.Create(Application);
  FrmClientes.Show;
end;

procedure TFrmPrincipal.mnuProductosClick(Sender: TObject);
begin
  FrmProductos := TFrmProductos.Create(Application);
  FrmProductos.Show;
end;

procedure TFrmPrincipal.mnuPedidosClick(Sender: TObject);
begin
  FrmPedidos := TFrmPedidos.Create(Application);
  FrmPedidos.Show;
end;

procedure TFrmPrincipal.mnuInformesClick(Sender: TObject);
begin
  if gNivelUsuario < 2 then
  begin
    ShowMessage('No tiene permiso para ver informes');
    Exit;
  end;
  FrmInformes := TFrmInformes.Create(Application);
  FrmInformes.ShowModal;
end;

end.
