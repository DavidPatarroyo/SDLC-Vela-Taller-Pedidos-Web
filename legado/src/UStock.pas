unit UStock;

{ manejo de stock }

interface

function StockDisponible(AIdProducto: Integer): Integer;
function DescontarStock(AIdProducto, ACantidad: Integer; AEsVip: Boolean): Boolean;
procedure DescontarStockPedido(AFolio: Integer; AEsVip: Boolean);
procedure RegistrarMovimiento(AIdProducto, ACantidad: Integer; const AMotivo: string);

implementation

uses
  SysUtils, Dialogs, DB, dbisamtb, UDMPrincipal, UGlobales;

function StockDisponible(AIdProducto: Integer): Integer;
begin
  Result := 0;
  with DMPrincipal.qryAux do
  begin
    Close;
    SQL.Text := 'SELECT STOCK FROM PRODUCTOS WHERE ID_PRODUCTO = ' +
      IntToStr(AIdProducto);
    Open;
    if not IsEmpty then
      Result := FieldByName('STOCK').AsInteger;
    Close;
  end;
end;

{ descuenta stock de un producto. devuelve False si no alcanza }
function DescontarStock(AIdProducto, ACantidad: Integer; AEsVip: Boolean): Boolean;
var
  vActual, vNuevo: Integer;
begin
  Result := False;
  vActual := StockDisponible(AIdProducto);
  vNuevo := vActual - ACantidad;
  if AEsVip then
  begin
    // los vip pueden quedar debiendo
    if vNuevo < -20 then
      Exit;
  end
  else
  begin
    if vNuevo < 0 then
      Exit;
  end;
  DMPrincipal.EjecutarSQL('UPDATE PRODUCTOS SET STOCK = ' + IntToStr(vNuevo) +
    ' WHERE ID_PRODUCTO = ' + IntToStr(AIdProducto));
  RegistrarMovimiento(AIdProducto, -ACantidad, 'PEDIDO');
  Result := True;
end;

procedure DescontarStockPedido(AFolio: Integer; AEsVip: Boolean);
var
  vQry: TDBISAMQuery;
begin
  vQry := TDBISAMQuery.Create(nil);
  try
    vQry.DatabaseName := 'PEDIDOS';
    vQry.SQL.Text := 'SELECT ID_PRODUCTO, CANTIDAD FROM PEDIDO_LINEAS ' +
      'WHERE FOLIO = ' + IntToStr(AFolio) + ' ORDER BY LINEA';
    vQry.Open;
    while not vQry.Eof do
    begin
      if not DescontarStock(vQry.FieldByName('ID_PRODUCTO').AsInteger,
        vQry.FieldByName('CANTIDAD').AsInteger, AEsVip) then
        ShowMessage('Sin stock suficiente para producto ' +
          vQry.FieldByName('ID_PRODUCTO').AsString);
      vQry.Next;
    end;
    vQry.Close;
  finally
    vQry.Free;
  end;
end;

{ deja registro del movimiento }
procedure RegistrarMovimiento(AIdProducto, ACantidad: Integer; const AMotivo: string);
begin
  try
    DMPrincipal.EjecutarSQL('INSERT INTO MOV_STOCK (ID_PRODUCTO, CANTIDAD, ' +
      'MOTIVO, USUARIO, FECHA) VALUES (' + IntToStr(AIdProducto) + ', ' +
      IntToStr(ACantidad) + ', ''' + AMotivo + ''', ''' + gUsuario + ''', ' +
      '''' + FormatDateTime('yyyy-mm-dd', Date) + ''')');
  except
  end;
end;

end.
