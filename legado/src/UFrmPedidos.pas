unit UFrmPedidos;

{ toma de pedidos }

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ExtCtrls, UCalculoTotales;

type
  TFrmPedidos = class(TForm)
    pnlCliente: TPanel;
    lblRut: TLabel;
    edtRutCliente: TEdit;
    btnBuscarCliente: TButton;
    lblCliente: TLabel;
    lblTipo: TLabel;
    lblRegion: TLabel;
    pnlLineas: TPanel;
    lblCodigo: TLabel;
    edtCodProducto: TEdit;
    lblCantidad: TLabel;
    edtCantidad: TEdit;
    btnAgregar: TButton;
    btnQuitar: TButton;
    sgLineas: TStringGrid;
    pnlTotales: TPanel;
    lblSubtotal: TLabel;
    lblDescuento: TLabel;
    lblFlete: TLabel;
    lblIva: TLabel;
    lblTotal: TLabel;
    lblObs: TLabel;
    memObs: TMemo;
    btnGrabar: TButton;
    btnNuevo: TButton;
    btnCerrar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnBuscarClienteClick(Sender: TObject);
    procedure btnAgregarClick(Sender: TObject);
    procedure btnQuitarClick(Sender: TObject);
    procedure btnGrabarClick(Sender: TObject);
    procedure btnNuevoClick(Sender: TObject);
    procedure btnCerrarClick(Sender: TObject);
  private
    FIdCliente: Integer;
    FEsVip: Boolean;
    FRegion: Integer;
    FFleteBase: Double;
    FLineas: TLineasCalculo;
    FProductos: array of Integer;
    FDescripciones: array of string;
    procedure Proc2;
    procedure LimpiarPantalla;
    procedure PintarGrilla;
  public
  end;

var
  FrmPedidos: TFrmPedidos;

implementation

uses
  DB, DateUtils, dbisamtb, UDMPrincipal, UGlobales, UUtilidades, UStock;

{$R *.dfm}

procedure TFrmPedidos.FormCreate(Sender: TObject);
begin
  sgLineas.Cells[0, 0] := 'Codigo';
  sgLineas.Cells[1, 0] := 'Descripcion';
  sgLineas.Cells[2, 0] := 'Cantidad';
  sgLineas.Cells[3, 0] := 'Precio';
  sgLineas.Cells[4, 0] := 'Total';
  LimpiarPantalla;
end;

procedure TFrmPedidos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmPedidos.btnBuscarClienteClick(Sender: TObject);
var
  vRut: string;
begin
  vRut := Trim(edtRutCliente.Text);
  if not ValidaRut(vRut) then
  begin
    ShowMessage('RUT invalido');
    Exit;
  end;
  with DMPrincipal.qryGeneral do
  begin
    Close;
    SQL.Text := 'SELECT C.ID_CLIENTE, C.RAZON_SOCIAL, C.TIPO, C.REGION, ' +
      'C.SALDO_VENCIDO, C.FECHA_VENCIMIENTO, R.NOMBRE, R.FLETE_BASE ' +
      'FROM CLIENTES C INNER JOIN REGIONES R ON R.CODIGO = C.REGION ' +
      'WHERE C.RUT = ''' + vRut + '''';
    Open;
    if IsEmpty then
    begin
      ShowMessage('Cliente no existe');
      Close;
      Exit;
    end;
    // con deuda vencida no se le vende
    if (FieldByName('SALDO_VENCIDO').AsFloat > 0) and
      (DaysBetween(Date, FieldByName('FECHA_VENCIMIENTO').AsDateTime) > 60) then
    begin
      ShowMessage('Cliente bloqueado por deuda vencida. Hablar con cobranza');
      Close;
      Exit;
    end;
    FIdCliente := FieldByName('ID_CLIENTE').AsInteger;
    FEsVip := FieldByName('TIPO').AsString = 'V';
    FRegion := FieldByName('REGION').AsInteger;
    FFleteBase := FieldByName('FLETE_BASE').AsFloat;
    lblCliente.Caption := FieldByName('RAZON_SOCIAL').AsString;
    if FEsVip then
      lblTipo.Caption := 'Cliente VIP'
    else
      lblTipo.Caption := 'Cliente normal';
    lblRegion.Caption := FieldByName('NOMBRE').AsString;
    Close;
  end;
  Proc2;
end;

procedure TFrmPedidos.btnAgregarClick(Sender: TObject);
var
  vCant, n: Integer;
begin
  if FIdCliente = 0 then
  begin
    ShowMessage('Primero busque el cliente');
    Exit;
  end;
  vCant := StrToIntDef(edtCantidad.Text, 0);
  if vCant <= 0 then
  begin
    ShowMessage('Cantidad invalida');
    Exit;
  end;
  with DMPrincipal.qryGeneral do
  begin
    Close;
    SQL.Text := 'SELECT ID_PRODUCTO, DESCRIPCION, CATEGORIA, PRECIO ' +
      'FROM PRODUCTOS WHERE CODIGO = ''' + Trim(edtCodProducto.Text) + '''';
    Open;
    if IsEmpty then
    begin
      ShowMessage('Producto no existe');
      Close;
      Exit;
    end;
    n := Length(FLineas);
    AgregarLinea(FLineas, vCant, FieldByName('PRECIO').AsFloat,
      FieldByName('CATEGORIA').AsString);
    SetLength(FProductos, n + 1);
    SetLength(FDescripciones, n + 1);
    FProductos[n] := FieldByName('ID_PRODUCTO').AsInteger;
    FDescripciones[n] := FieldByName('DESCRIPCION').AsString;
    Close;
  end;
  edtCodProducto.Text := '';
  edtCantidad.Text := '';
  PintarGrilla;
  Proc2;
end;

procedure TFrmPedidos.btnQuitarClick(Sender: TObject);
var
  i, vIdx: Integer;
begin
  vIdx := sgLineas.Row - 1;
  if (vIdx < 0) or (vIdx > High(FLineas)) then
    Exit;
  QuitarLinea(FLineas, vIdx);
  for i := vIdx to High(FProductos) - 1 do
  begin
    FProductos[i] := FProductos[i + 1];
    FDescripciones[i] := FDescripciones[i + 1];
  end;
  SetLength(FProductos, Length(FProductos) - 1);
  SetLength(FDescripciones, Length(FDescripciones) - 1);
  PintarGrilla;
  Proc2;
end;

{ graba el pedido }
procedure TFrmPedidos.btnGrabarClick(Sender: TObject);
var
  vFolio, i: Integer;
  vFecha: TDateTime;
  vSubtotal, vBruto, vBase, vPorc, vDesc, vNeto, vFlete, vIva, vTotal: Double;
  vSql, vObs: string;
  vQry: TDBISAMQuery;
begin
  // validaciones
  if FIdCliente = 0 then
  begin
    ShowMessage('Falta el cliente');
    Exit;
  end;
  if Length(FLineas) = 0 then
  begin
    ShowMessage('El pedido no tiene lineas');
    Exit;
  end;
  if Length(FLineas) > 40 then
  begin
    ShowMessage('Maximo 40 lineas por pedido');
    Exit;
  end;
  for i := 0 to High(FLineas) do
  begin
    if FLineas[i].PrecioUnitario <= 0 then
    begin
      ShowMessage('Linea ' + IntToStr(i + 1) + ' sin precio');
      Exit;
    end;
  end;
  vSubtotal := 0;
  for i := 0 to High(FLineas) do
    vSubtotal := vSubtotal + FLineas[i].Cantidad * FLineas[i].PrecioUnitario;
  // pedido minimo, santiago no tiene minimo
  if (vSubtotal < 30000) and (FRegion <> 13) then
  begin
    ShowMessage('El pedido minimo es de $30.000');
    Exit;
  end;
  if MessageDlg('Confirma el pedido?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  // fecha del pedido
  vFecha := FechaParaPedido(Now);
  if vFecha <> Date then
    ShowMessage('Pedido ingresado fuera de horario. Queda con fecha ' +
      FechaAStr(vFecha));

  // folio
  with DMPrincipal.qryAux do
  begin
    Close;
    SQL.Text := 'SELECT MAX(FOLIO) AS ULTIMO FROM PEDIDOS';
    Open;
    vFolio := FieldByName('ULTIMO').AsInteger + 1;
    Close;
  end;

  // TODO transaccion
  vObs := memObs.Lines.Text;
  if Length(vObs) > 200 then
    vObs := Copy(vObs, 1, 200);
  vSql := 'INSERT INTO PEDIDOS (FOLIO, FECHA, ID_CLIENTE, USUARIO, ESTADO, ' +
    'OBSERVACION, TOTAL) VALUES (' + IntToStr(vFolio) + ', ' +
    FechaSQL(vFecha) + ', ' + IntToStr(FIdCliente) + ', ''' + gUsuario +
    ''', ''C'', ''' + vObs + ''', 0)';
  DMPrincipal.EjecutarSQL(vSql);

  // lineas
  for i := 0 to High(FLineas) do
  begin
    vSql := 'INSERT INTO PEDIDO_LINEAS (FOLIO, LINEA, ID_PRODUCTO, CANTIDAD, ' +
      'PRECIO_UNITARIO) VALUES (' + IntToStr(vFolio) + ', ' + IntToStr(i + 1) +
      ', ' + IntToStr(FProductos[i]) + ', ' + IntToStr(FLineas[i].Cantidad) +
      ', ' + FloatToStr(FLineas[i].PrecioUnitario) + ')';
    DMPrincipal.EjecutarSQL(vSql);
  end;

  // recalcula con lo grabado
  vQry := TDBISAMQuery.Create(nil);
  try
    vQry.DatabaseName := 'PEDIDOS';
    vQry.SQL.Text := 'SELECT SUM(L.CANTIDAD * L.PRECIO_UNITARIO) AS BRUTO ' +
      'FROM PEDIDO_LINEAS L WHERE L.FOLIO = ' + IntToStr(vFolio);
    vQry.Open;
    vBruto := vQry.FieldByName('BRUTO').AsFloat;
    vQry.Close;
    vQry.SQL.Text := 'SELECT SUM(L.CANTIDAD * L.PRECIO_UNITARIO) AS BASE ' +
      'FROM PEDIDO_LINEAS L, PRODUCTOS P ' +
      'WHERE P.ID_PRODUCTO = L.ID_PRODUCTO AND L.FOLIO = ' + IntToStr(vFolio) +
      ' AND P.CATEGORIA <> ''OFE''';
    vQry.Open;
    vBase := vQry.FieldByName('BASE').AsFloat;
    vQry.Close;
  finally
    vQry.Free;
  end;

  // descuento
  if vBase >= 1000000 then
    vPorc := 0.08
  else if vBase >= 500000 then
    vPorc := 0.05
  else
    vPorc := 0;
  if FEsVip then
    vPorc := vPorc + 0.03;
  if gDescNavidad and (MonthOf(vFecha) = 12) then
    vPorc := vPorc + 0.02;
  if vPorc > 0.10 then
    vPorc := 0.10;
  vDesc := RedondeaPesos(vBase * vPorc);
  vNeto := vBruto - vDesc;

  // flete
  if (FRegion = 11) or (FRegion = 12) then
    vFlete := RedondeaPesos(FFleteBase * 1.15)
  else
    vFlete := RedondeaPesos(FFleteBase);

  // iva y total
  vIva := RedondeaPesos((vNeto + vFlete) * gTasaIVA);
  vTotal := vNeto + vFlete + vIva;
  DMPrincipal.EjecutarSQL('UPDATE PEDIDOS SET TOTAL = ' + FloatToStr(vTotal) +
    ' WHERE FOLIO = ' + IntToStr(vFolio));

  // stock
  DescontarStockPedido(vFolio, FEsVip);

  // aviso a vendedor si el total cambio
  if Abs(vTotal - CalcularTotales(FLineas, FEsVip, FRegion, FFleteBase,
    gTasaIVA).Total) > 1 then
  begin
    if gModoPrueba then
      ShowMessage('Diferencia de total en folio ' + IntToStr(vFolio));
  end;

  // log simple
  with DMPrincipal.qryAux do
  begin
    Close;
    SQL.Text := 'SELECT COUNT(*) AS N FROM PEDIDOS WHERE ID_CLIENTE = ' +
      IntToStr(FIdCliente);
    Open;
    if FieldByName('N').AsInteger = 1 then
      ShowMessage('Primer pedido del cliente. Avisar a cobranza');
    Close;
  end;

  gUltimoFolio := vFolio;
  ShowMessage('Pedido grabado con folio ' + IntToStr(vFolio) + #13 +
    'Total: ' + FormatoPesos(vTotal));
  LimpiarPantalla;
end;

procedure TFrmPedidos.btnNuevoClick(Sender: TObject);
begin
  if Length(FLineas) > 0 then
    if MessageDlg('Descartar el pedido actual?', mtConfirmation,
      [mbYes, mbNo], 0) <> mrYes then
      Exit;
  LimpiarPantalla;
end;

procedure TFrmPedidos.btnCerrarClick(Sender: TObject);
begin
  Close;
end;

{ muestra totales en pantalla }
procedure TFrmPedidos.Proc2;
var
  r: TResultadoTotales;
begin
  r := CalcularTotales(FLineas, FEsVip, FRegion, FFleteBase, gTasaIVA);
  lblSubtotal.Caption := 'Subtotal:  ' + FormatoPesos(r.Subtotal);
  lblDescuento.Caption := 'Descuento: ' + FormatoPesos(r.Descuento);
  lblFlete.Caption := 'Flete:     ' + FormatoPesos(r.Flete);
  lblIva.Caption := 'IVA:       ' + FormatoPesos(r.Iva);
  lblTotal.Caption := 'TOTAL:     ' + FormatoPesos(r.Total);
end;

procedure TFrmPedidos.LimpiarPantalla;
begin
  FIdCliente := 0;
  FEsVip := False;
  FRegion := 0;
  FFleteBase := 0;
  SetLength(FLineas, 0);
  SetLength(FProductos, 0);
  SetLength(FDescripciones, 0);
  edtRutCliente.Text := '';
  edtCodProducto.Text := '';
  edtCantidad.Text := '';
  lblCliente.Caption := '';
  lblTipo.Caption := '';
  lblRegion.Caption := '';
  memObs.Lines.Clear;
  PintarGrilla;
  Proc2;
end;

procedure TFrmPedidos.PintarGrilla;
var
  i: Integer;
begin
  if Length(FLineas) = 0 then
    sgLineas.RowCount := 2
  else
    sgLineas.RowCount := Length(FLineas) + 1;
  for i := 0 to 4 do
    sgLineas.Cells[i, 1] := '';
  for i := 0 to High(FLineas) do
  begin
    sgLineas.Cells[0, i + 1] := IntToStr(FProductos[i]);
    sgLineas.Cells[1, i + 1] := FDescripciones[i];
    sgLineas.Cells[2, i + 1] := IntToStr(FLineas[i].Cantidad);
    sgLineas.Cells[3, i + 1] := FormatoPesos(FLineas[i].PrecioUnitario);
    sgLineas.Cells[4, i + 1] := FormatoPesos(FLineas[i].Cantidad *
      FLineas[i].PrecioUnitario);
  end;
end;

end.
