unit UCalculoTotales;

{ calculo de totales del pedido
  descuento por volumen 5% sobre 400.000 (acta comercial 2011)
  NO TOCAR sin hablar con contabilidad }

interface

type
  TLineaCalculo = record
    Cantidad: Integer;
    PrecioUnitario: Double;
    Categoria: string;
  end;

  TLineasCalculo = array of TLineaCalculo;

  TResultadoTotales = record
    Subtotal: Double;
    BaseDescuento: Double;
    PorcDescuento: Double;
    Descuento: Double;
    Neto: Double;
    Flete: Double;
    Iva: Double;
    Total: Double;
  end;

function Calc3(AValor: Double): Double;
function CalcularSubtotal(const ALineas: TLineasCalculo): Double;
function CalcularBaseDescuento(const ALineas: TLineasCalculo): Double;
function PorcentajeVolumen(ABase: Double): Double;
function PorcentajeDescuento(ABase: Double; AEsVip: Boolean): Double;
function CalcularFlete(AFleteBase: Double; ARegion: Integer): Double;
function CalcularIva(ANeto, AFlete, ATasa: Double): Double;
function CalcularTotales(const ALineas: TLineasCalculo; AEsVip: Boolean;
  ARegion: Integer; AFleteBase, ATasaIva: Double): TResultadoTotales;
procedure AgregarLinea(var ALineas: TLineasCalculo; ACantidad: Integer;
  APrecio: Double; const ACategoria: string);
procedure QuitarLinea(var ALineas: TLineasCalculo; AIndice: Integer);

implementation

uses
  SysUtils;

{ redondeo al peso }
function Calc3(AValor: Double): Double;
begin
  Result := Trunc(AValor + 0.49);
end;

function CalcularSubtotal(const ALineas: TLineasCalculo): Double;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to High(ALineas) do
    Result := Result + ALineas[i].Cantidad * ALineas[i].PrecioUnitario;
end;

{ suma de las lineas que entran al descuento }
function CalcularBaseDescuento(const ALineas: TLineasCalculo): Double;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to High(ALineas) do
  begin
    if UpperCase(Trim(ALineas[i].Categoria)) <> 'OFE' then
      Result := Result + ALineas[i].Cantidad * ALineas[i].PrecioUnitario;
  end;
end;

function PorcentajeVolumen(ABase: Double): Double;
begin
  if ABase > 1000000 then
    Result := 0.08
  else if ABase > 500000 then
    Result := 0.05
  else
    Result := 0;
end;

function PorcentajeDescuento(ABase: Double; AEsVip: Boolean): Double;
begin
  Result := PorcentajeVolumen(ABase);
  if AEsVip then
    Result := Result + 0.03;
  if Result > 0.10 then
    Result := 0.10;
end;

{ flete por region }
function CalcularFlete(AFleteBase: Double; ARegion: Integer): Double;
begin
  if (ARegion = 11) or (ARegion = 12) then
    Result := Calc3(AFleteBase * 1.15)
  else
    Result := Calc3(AFleteBase);
end;

function CalcularIva(ANeto, AFlete, ATasa: Double): Double;
begin
  Result := Calc3((ANeto + AFlete) * ATasa);
end;

function CalcularTotales(const ALineas: TLineasCalculo; AEsVip: Boolean;
  ARegion: Integer; AFleteBase, ATasaIva: Double): TResultadoTotales;
begin
  Result.Subtotal := CalcularSubtotal(ALineas);
  Result.BaseDescuento := CalcularBaseDescuento(ALineas);
  Result.PorcDescuento := PorcentajeDescuento(Result.BaseDescuento, AEsVip);
  Result.Descuento := Calc3(Result.BaseDescuento * Result.PorcDescuento);
  Result.Neto := Result.Subtotal - Result.Descuento;
  if Length(ALineas) = 0 then
    Result.Flete := 0
  else
    Result.Flete := CalcularFlete(AFleteBase, ARegion);
  Result.Iva := CalcularIva(Result.Neto, Result.Flete, ATasaIva);
  Result.Total := Result.Neto + Result.Flete + Result.Iva;
end;

procedure AgregarLinea(var ALineas: TLineasCalculo; ACantidad: Integer;
  APrecio: Double; const ACategoria: string);
var
  n: Integer;
begin
  n := Length(ALineas);
  SetLength(ALineas, n + 1);
  ALineas[n].Cantidad := ACantidad;
  ALineas[n].PrecioUnitario := APrecio;
  ALineas[n].Categoria := ACategoria;
end;

procedure QuitarLinea(var ALineas: TLineasCalculo; AIndice: Integer);
var
  i: Integer;
begin
  if (AIndice < 0) or (AIndice > High(ALineas)) then
    Exit;
  for i := AIndice to High(ALineas) - 1 do
    ALineas[i] := ALineas[i + 1];
  SetLength(ALineas, Length(ALineas) - 1);
end;

end.
