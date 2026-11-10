unit UFrmClientes;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, DBGrids, DB, DBCtrls, ExtCtrls, dbisamtb;

type
  TFrmClientes = class(TForm)
    tblCli: TDBISAMTable;
    dsCli: TDataSource;
    pnlBuscar: TPanel;
    lblBuscar: TLabel;
    edtBuscar: TEdit;
    btnBuscar: TButton;
    grdClientes: TDBGrid;
    pnlDatos: TPanel;
    lblRut: TLabel;
    dbeRut: TDBEdit;
    lblRazon: TLabel;
    dbeRazon: TDBEdit;
    lblTipo: TLabel;
    dbeTipo: TDBEdit;
    lblRegion: TLabel;
    dbeRegion: TDBEdit;
    lblDireccion: TLabel;
    dbeDireccion: TDBEdit;
    lblTelefono: TLabel;
    dbeTelefono: TDBEdit;
    btnNuevo: TButton;
    btnGrabar: TButton;
    btnEliminar: TButton;
    btnCerrar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnBuscarClick(Sender: TObject);
    procedure btnNuevoClick(Sender: TObject);
    procedure btnGrabarClick(Sender: TObject);
    procedure btnEliminarClick(Sender: TObject);
    procedure btnCerrarClick(Sender: TObject);
    procedure tblCliBeforePost(DataSet: TDataSet);
  private
    function RutOk(const ARut: string): Boolean;
    function TienePedidos(AIdCliente: Integer): Boolean;
  public
  end;

var
  FrmClientes: TFrmClientes;

implementation

uses
  UDMPrincipal, UGlobales;

{$R *.dfm}

procedure TFrmClientes.FormCreate(Sender: TObject);
begin
  tblCli.Open;
end;

procedure TFrmClientes.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  tblCli.Close;
  Action := caFree;
end;

{ busqueda por razon social }
procedure TFrmClientes.btnBuscarClick(Sender: TObject);
begin
  with DMPrincipal.qryGeneral do
  begin
    Close;
    SQL.Text := 'SELECT ID_CLIENTE FROM CLIENTES WHERE RAZON_SOCIAL LIKE ''' +
      edtBuscar.Text + '%''';
    Open;
    if IsEmpty then
      ShowMessage('No se encontraron clientes')
    else
      tblCli.Locate('ID_CLIENTE', FieldByName('ID_CLIENTE').AsInteger, []);
    Close;
  end;
end;

procedure TFrmClientes.btnNuevoClick(Sender: TObject);
begin
  tblCli.Append;
  tblCli.FieldByName('TIPO').AsString := 'N';
  tblCli.FieldByName('REGION').AsInteger := 13;
  tblCli.FieldByName('SALDO_VENCIDO').AsFloat := 0;
  tblCli.FieldByName('ACTIVO').AsBoolean := True;
  dbeRut.SetFocus;
end;

procedure TFrmClientes.btnGrabarClick(Sender: TObject);
begin
  if tblCli.State in [dsEdit, dsInsert] then
    tblCli.Post;
end;

procedure TFrmClientes.btnEliminarClick(Sender: TObject);
begin
  if tblCli.IsEmpty then
    Exit;
  if TienePedidos(tblCli.FieldByName('ID_CLIENTE').AsInteger) then
  begin
    ShowMessage('El cliente tiene pedidos, no se puede eliminar');
    Exit;
  end;
  if MessageDlg('Eliminar cliente?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    tblCli.Delete;
end;

procedure TFrmClientes.btnCerrarClick(Sender: TObject);
begin
  Close;
end;

{ validaciones antes de grabar }
procedure TFrmClientes.tblCliBeforePost(DataSet: TDataSet);
var
  vTipo: string;
begin
  if not RutOk(DataSet.FieldByName('RUT').AsString) then
  begin
    ShowMessage('RUT no valido');
    Abort;
  end;
  if Trim(DataSet.FieldByName('RAZON_SOCIAL').AsString) = '' then
  begin
    ShowMessage('Falta la razon social');
    Abort;
  end;
  vTipo := UpperCase(Trim(DataSet.FieldByName('TIPO').AsString));
  if (vTipo <> 'N') and (vTipo <> 'V') then
  begin
    ShowMessage('Tipo debe ser N o V');
    Abort;
  end;
  // solo jefatura crea clientes vip
  if (vTipo = 'V') and (gNivelUsuario < 2) then
  begin
    ShowMessage('Solo jefatura puede marcar clientes VIP');
    Abort;
  end;
  if (DataSet.FieldByName('REGION').AsInteger < 1) or
    (DataSet.FieldByName('REGION').AsInteger > 16) then
  begin
    ShowMessage('Region no existe');
    Abort;
  end;
  DataSet.FieldByName('TIPO').AsString := vTipo;
  if DataSet.State = dsInsert then
  begin
    with DMPrincipal.qryAux do
    begin
      Close;
      SQL.Text := 'SELECT MAX(ID_CLIENTE) AS ULTIMO FROM CLIENTES';
      Open;
      DataSet.FieldByName('ID_CLIENTE').AsInteger :=
        FieldByName('ULTIMO').AsInteger + 1;
      Close;
    end;
  end;
end;

{ valida el rut del cliente }
function TFrmClientes.RutOk(const ARut: string): Boolean;
var
  vRut, vDv: string;
  i, vSuma, vMult, vRes: Integer;
begin
  vRut := '';
  for i := 1 to Length(ARut) do
    if ARut[i] in ['0'..'9', 'k', 'K'] then
      vRut := vRut + ARut[i];
  vRut := UpperCase(vRut);
  Result := False;
  if Length(vRut) < 2 then
    Exit;
  vSuma := 0;
  vMult := 2;
  for i := Length(vRut) - 1 downto 1 do
  begin
    vSuma := vSuma + (Ord(vRut[i]) - Ord('0')) * vMult;
    vMult := vMult + 1;
    if vMult = 8 then
      vMult := 2;
  end;
  vRes := 11 - (vSuma mod 11);
  if vRes = 11 then
    vDv := 'K'
  else if vRes = 10 then
    vDv := '0'
  else
    vDv := IntToStr(vRes);
  Result := vDv = vRut[Length(vRut)];
end;

function TFrmClientes.TienePedidos(AIdCliente: Integer): Boolean;
begin
  with DMPrincipal.qryAux do
  begin
    Close;
    SQL.Text := 'SELECT COUNT(*) AS N FROM PEDIDOS WHERE ID_CLIENTE = ' +
      IntToStr(AIdCliente);
    Open;
    Result := FieldByName('N').AsInteger > 0;
    Close;
  end;
end;

end.
