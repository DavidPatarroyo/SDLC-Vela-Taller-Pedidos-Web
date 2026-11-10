unit UGlobales;

{ variables globales del sistema
  ojo: se modifican desde varios formularios }

interface

const
  VERSION_SISTEMA = '2.3.1';

var
  gUsuario: string;
  gNivelUsuario: Integer;      // 1 = vendedor, 2 = supervisor, 9 = admin
  gTasaIVA: Double;
  gFleteBase: Double;          // flete por defecto
  gDescNavidad: Boolean;
  gModoPrueba: Boolean;
  gUltimoFolio: Integer;
  gRutaDatos: string;
  gImpresora: string;
  gFechaSistema: TDateTime;

procedure InicializarGlobales;

implementation

procedure InicializarGlobales;
begin
  gUsuario := '';
  gNivelUsuario := 1;
  gTasaIVA := 0.19;
  gFleteBase := 3500;
  gDescNavidad := False;       // promo navidad 2009
  gModoPrueba := False;
  gUltimoFolio := 0;
  gRutaDatos := 'C:\PEDIDOS\DATOS';
  gImpresora := 'LPT1';
  gFechaSistema := 0;
end;

end.
