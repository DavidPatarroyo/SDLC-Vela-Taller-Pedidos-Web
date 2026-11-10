unit UFrmInformes;

{ informe de ventas por rango de fechas }

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, DBGrids, DB, ExtCtrls, dbisamtb;

type
  TFrmInformes = class(TForm)
    qryInforme: TDBISAMQuery;
    dsInforme: TDataSource;
    pnlFiltros: TPanel;
    lblDesde: TLabel;
    edtDesde: TEdit;
    lblHasta: TLabel;
    edtHasta: TEdit;
    lblClienteFiltro: TLabel;
    edtCliente: TEdit;
    chkSoloConfirmados: TCheckBox;
    btnGenerar: TButton;
    btnExportar: TButton;
    grdInforme: TDBGrid;
    pnlResumen: TPanel;
    lblCantidad: TLabel;
    lblTotalNeto: TLabel;
    lblTotalIva: TLabel;
    lblTotalGeneral: TLabel;
    btnCerrar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnGenerarClick(Sender: TObject);
    procedure btnExportarClick(Sender: TObject);
    procedure btnCerrarClick(Sender: TObject);
  private
  public
  end;

var
  FrmInformes: TFrmInformes;

implementation

uses
  DateUtils, UGlobales, UUtilidades;

{$R *.dfm}

procedure TFrmInformes.FormCreate(Sender: TObject);
begin
  edtDesde.Text := FechaAStr(StartOfTheMonth(Date));
  edtHasta.Text := FechaAStr(Date);
end;

procedure TFrmInformes.btnGenerarClick(Sender: TObject);
var
  vDesde, vHasta: TDateTime;
  vSql: string;
  vTotal, vNeto, vIva: Double;
  vCant: Integer;
begin
  vDesde := StrAFecha(edtDesde.Text);
  vHasta := StrAFecha(edtHasta.Text);
  vSql := 'SELECT P.FOLIO, P.FECHA, C.RAZON_SOCIAL, P.USUARIO, P.TOTAL ' +
    'FROM PEDIDOS P INNER JOIN CLIENTES C ON C.ID_CLIENTE = P.ID_CLIENTE ' +
    'WHERE P.FECHA >= ' + FechaSQL(vDesde) + ' AND P.FECHA <= ' + FechaSQL(vHasta);
  if Trim(edtCliente.Text) <> '' then
    vSql := vSql + ' AND C.RAZON_SOCIAL LIKE ''%' + edtCliente.Text + '%''';
  if chkSoloConfirmados.Checked then
    vSql := vSql + ' AND P.ESTADO = ''C''';
  vSql := vSql + ' ORDER BY P.FECHA, P.FOLIO';
  qryInforme.Close;
  qryInforme.SQL.Text := vSql;
  qryInforme.Open;
  vTotal := 0;
  vCant := 0;
  qryInforme.DisableControls;
  try
    qryInforme.First;
    while not qryInforme.Eof do
    begin
      vTotal := vTotal + qryInforme.FieldByName('TOTAL').AsFloat;
      Inc(vCant);
      qryInforme.Next;
    end;
    qryInforme.First;
  finally
    qryInforme.EnableControls;
  end;
  // el total viene con iva
  vNeto := vTotal / (1 + 0.19);
  vIva := vTotal - vNeto;
  lblCantidad.Caption := 'Pedidos: ' + IntToStr(vCant);
  lblTotalNeto.Caption := 'Neto: ' + FormatoPesos(vNeto);
  lblTotalIva.Caption := 'IVA: ' + FormatoPesos(vIva);
  lblTotalGeneral.Caption := 'Total: ' + FormatoPesos(vTotal);
end;

{ exporta a csv para contabilidad }
procedure TFrmInformes.btnExportarClick(Sender: TObject);
var
  vLista: TStringList;
  vArchivo: string;
begin
  if not qryInforme.Active then
  begin
    ShowMessage('Primero genere el informe');
    Exit;
  end;
  vArchivo := gRutaDatos + '\informe_' + FormatDateTime('yyyymmdd', Date) + '.csv';
  vLista := TStringList.Create;
  try
    vLista.Add('FOLIO;FECHA;CLIENTE;USUARIO;TOTAL');
    qryInforme.First;
    while not qryInforme.Eof do
    begin
      vLista.Add(qryInforme.FieldByName('FOLIO').AsString + ';' +
        FechaAStr(qryInforme.FieldByName('FECHA').AsDateTime) + ';' +
        qryInforme.FieldByName('RAZON_SOCIAL').AsString + ';' +
        qryInforme.FieldByName('USUARIO').AsString + ';' +
        FormatFloat('0', qryInforme.FieldByName('TOTAL').AsFloat));
      qryInforme.Next;
    end;
    vLista.SaveToFile(vArchivo);
    ShowMessage('Archivo generado: ' + vArchivo);
  finally
    vLista.Free;
  end;
end;

procedure TFrmInformes.btnCerrarClick(Sender: TObject);
begin
  Close;
end;

end.
