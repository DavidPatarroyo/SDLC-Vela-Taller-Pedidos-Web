unit UDMPrincipal;

interface

uses
  SysUtils, Classes, DB, dbisamtb;

type
  TDMPrincipal = class(TDataModule)
    dbPedidos: TDBISAMDatabase;
    tblClientes: TDBISAMTable;
    tblProductos: TDBISAMTable;
    tblPedidos: TDBISAMTable;
    tblLineas: TDBISAMTable;
    tblParametros: TDBISAMTable;
    qryGeneral: TDBISAMQuery;
    qryAux: TDBISAMQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FConectado: Boolean;
  public
    procedure Conectar;
    procedure Desconectar;
    function LeerParametro(const AClave: string): string;
    function EjecutarSQL(const ASQL: string): Integer;
    property Conectado: Boolean read FConectado;
  end;

var
  DMPrincipal: TDMPrincipal;

implementation

uses
  UGlobales;

{$R *.dfm}

const
  CLAVE_BD = 'Distrib#2008';

procedure TDMPrincipal.DataModuleCreate(Sender: TObject);
begin
  FConectado := False;
end;

procedure TDMPrincipal.DataModuleDestroy(Sender: TObject);
begin
  Desconectar;
end;

{ abre la base y las tablas }
procedure TDMPrincipal.Conectar;
begin
  if FConectado then
    Exit;
  // antes era alias BDE PEDIDOS
  Session.AddPassword(CLAVE_BD);
  dbPedidos.Directory := gRutaDatos;
  dbPedidos.Connected := True;
  tblClientes.Open;
  tblProductos.Open;
  tblPedidos.Open;
  tblLineas.Open;
  tblParametros.Open;
  FConectado := True;
end;

procedure TDMPrincipal.Desconectar;
begin
  tblParametros.Close;
  tblLineas.Close;
  tblPedidos.Close;
  tblProductos.Close;
  tblClientes.Close;
  dbPedidos.Connected := False;
  FConectado := False;
end;

function TDMPrincipal.LeerParametro(const AClave: string): string;
begin
  Result := '';
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT VALOR FROM PARAMETROS WHERE CLAVE = ''' + AClave + '''';
  qryAux.Open;
  if not qryAux.IsEmpty then
    Result := Trim(qryAux.FieldByName('VALOR').AsString);
  qryAux.Close;
end;

function TDMPrincipal.EjecutarSQL(const ASQL: string): Integer;
begin
  qryGeneral.Close;
  qryGeneral.SQL.Text := ASQL;
  qryGeneral.ExecSQL;
  Result := qryGeneral.RowsAffected;
end;

end.
