unit UUtilidades;

{ funciones varias }

interface

function RedondeaPesos(AValor: Double): Double;
function FormatoPesos(AValor: Double): string;
function LimpiaRut(const ARut: string): string;
function ValidaRut(const ARut: string): Boolean;
function FormateaRut(const ARut: string): string;
function StrAFecha(const ATexto: string): TDateTime;
function FechaAStr(AFecha: TDateTime): string;
function FechaSQL(AFecha: TDateTime): string;
function EsDiaHabil(AFecha: TDateTime): Boolean;
function FechaParaPedido(AMomento: TDateTime): TDateTime;
function SoloNumeros(const ATexto: string): string;
function Rellena(const ATexto: string; ALargo: Integer): string;
function EscapaComillas(const ATexto: string): string;
function NombreMes(AMes: Integer): string;

implementation

uses
  SysUtils, DateUtils;

{ redondeo al peso (igual que en totales) }
function RedondeaPesos(AValor: Double): Double;
begin
  Result := Trunc(AValor + 0.49);
end;

function FormatoPesos(AValor: Double): string;
begin
  Result := '$ ' + FormatFloat('#,##0', AValor);
end;

{ deja solo numeros y digito verificador }
function LimpiaRut(const ARut: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(ARut) do
  begin
    if (ARut[i] <> '.') and (ARut[i] <> '-') and (ARut[i] <> ' ') then
      Result := Result + ARut[i];
  end;
end;

{ valida rut con modulo 11 }
function ValidaRut(const ARut: string): Boolean;
var
  vRut, vCuerpo, vDv, vCalc: string;
  i, vSuma, vFactor, vResto: Integer;
begin
  Result := False;
  vRut := LimpiaRut(ARut);
  if Length(vRut) < 2 then
    Exit;
  vCuerpo := Copy(vRut, 1, Length(vRut) - 1);
  vDv := Copy(vRut, Length(vRut), 1);
  vSuma := 0;
  vFactor := 2;
  for i := Length(vCuerpo) downto 1 do
  begin
    vSuma := vSuma + StrToIntDef(vCuerpo[i], 0) * vFactor;
    Inc(vFactor);
    if vFactor > 7 then
      vFactor := 2;
  end;
  vResto := 11 - (vSuma mod 11);
  if vResto = 11 then
    vCalc := '0'
  else if vResto = 10 then
    vCalc := 'K'
  else
    vCalc := IntToStr(vResto);
  Result := vDv = vCalc;
end;

function FormateaRut(const ARut: string): string;
var
  vRut: string;
begin
  vRut := LimpiaRut(ARut);
  if Length(vRut) < 2 then
  begin
    Result := ARut;
    Exit;
  end;
  Result := Copy(vRut, 1, Length(vRut) - 1) + '-' + Copy(vRut, Length(vRut), 1);
end;

{ convierte dd/mm/yy a fecha }
function StrAFecha(const ATexto: string): TDateTime;
var
  vDia, vMes, vAnio: Word;
begin
  vDia := StrToInt(Copy(ATexto, 1, 2));
  vMes := StrToInt(Copy(ATexto, 4, 2));
  vAnio := StrToInt(Copy(ATexto, 7, 2));
  if vAnio < 50 then
    vAnio := vAnio + 2000
  else
    vAnio := vAnio + 1900;
  Result := EncodeDate(vAnio, vMes, vDia);
end;

function FechaAStr(AFecha: TDateTime): string;
begin
  Result := FormatDateTime('dd/mm/yy', AFecha);
end;

{ formato que entiende DBISAM }
function FechaSQL(AFecha: TDateTime): string;
begin
  Result := '''' + FormatDateTime('yyyy-mm-dd', AFecha) + '''';
end;

{ lunes a viernes }
function EsDiaHabil(AFecha: TDateTime): Boolean;
begin
  Result := DayOfTheWeek(AFecha) <= 5;
end;

{ pedidos despues del cierre pasan al dia siguiente }
function FechaParaPedido(AMomento: TDateTime): TDateTime;
var
  vFecha: TDateTime;
begin
  vFecha := DateOf(AMomento);
  if HourOf(AMomento) >= 18 then
  begin
    vFecha := IncDay(vFecha, 1);
    while not EsDiaHabil(vFecha) do
      vFecha := IncDay(vFecha, 1);
  end;
  Result := vFecha;
end;

function SoloNumeros(const ATexto: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(ATexto) do
  begin
    if ATexto[i] in ['0'..'9'] then
      Result := Result + ATexto[i];
  end;
end;

function Rellena(const ATexto: string; ALargo: Integer): string;
begin
  Result := ATexto;
  while Length(Result) < ALargo do
    Result := Result + ' ';
  if Length(Result) > ALargo then
    Result := Copy(Result, 1, ALargo);
end;

{ para usar en los sql }
function EscapaComillas(const ATexto: string): string;
begin
  Result := StringReplace(ATexto, '''', '''''', [rfReplaceAll]);
end;

function NombreMes(AMes: Integer): string;
begin
  case AMes of
    1: Result := 'Enero';
    2: Result := 'Febrero';
    3: Result := 'Marzo';
    4: Result := 'Abril';
    5: Result := 'Mayo';
    6: Result := 'Junio';
    7: Result := 'Julio';
    8: Result := 'Agosto';
    9: Result := 'Septiembre';
    10: Result := 'Octubre';
    11: Result := 'Noviembre';
    12: Result := 'Diciembre';
  else
    Result := '';
  end;
end;

end.
