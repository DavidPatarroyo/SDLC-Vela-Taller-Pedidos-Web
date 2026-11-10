unit UFrmProductos;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, DBGrids, DB, DBCtrls, ExtCtrls, dbisamtb;

type
  TFrmProductos = class(TForm)
    tblProd: TDBISAMTable;
    dsProd: TDataSource;
    pnlFiltro: TPanel;
    lblFiltro: TLabel;
    edtFiltro: TEdit;
    btnFiltrar: TButton;
    chkBajoMinimo: TCheckBox;
    grdProductos: TDBGrid;
    navProductos: TDBNavigator;
    btnCerrar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnFiltrarClick(Sender: TObject);
    procedure btnCerrarClick(Sender: TObject);
    procedure tblProdBeforePost(DataSet: TDataSet);
  private
  public
  end;

var
  FrmProductos: TFrmProductos;

implementation

uses
  UGlobales;

{$R *.dfm}

procedure TFrmProductos.FormCreate(Sender: TObject);
begin
  tblProd.Open;
  // solo admin puede borrar
  if gNivelUsuario < 9 then
    navProductos.VisibleButtons := navProductos.VisibleButtons - [nbDelete];
end;

procedure TFrmProductos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  tblProd.Filtered := False;
  tblProd.Close;
  Action := caFree;
end;

procedure TFrmProductos.btnFiltrarClick(Sender: TObject);
var
  vFiltro: string;
begin
  vFiltro := '';
  if Trim(edtFiltro.Text) <> '' then
    vFiltro := 'DESCRIPCION LIKE ''%' + UpperCase(edtFiltro.Text) + '%''';
  if chkBajoMinimo.Checked then
  begin
    if vFiltro <> '' then
      vFiltro := vFiltro + ' AND ';
    vFiltro := vFiltro + 'STOCK < STOCK_MINIMO';
  end;
  tblProd.Filtered := False;
  tblProd.Filter := vFiltro;
  tblProd.Filtered := vFiltro <> '';
end;

procedure TFrmProductos.btnCerrarClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmProductos.tblProdBeforePost(DataSet: TDataSet);
var
  vCat: string;
begin
  if Trim(DataSet.FieldByName('CODIGO').AsString) = '' then
  begin
    ShowMessage('Falta el codigo');
    Abort;
  end;
  if DataSet.FieldByName('PRECIO').AsFloat <= 0 then
  begin
    ShowMessage('El precio debe ser mayor que cero');
    Abort;
  end;
  vCat := UpperCase(Trim(DataSet.FieldByName('CATEGORIA').AsString));
  if Length(vCat) <> 3 then
  begin
    ShowMessage('Categoria debe tener 3 letras (ABA, BEB, LIM, OFE...)');
    Abort;
  end;
  DataSet.FieldByName('CATEGORIA').AsString := vCat;
  DataSet.FieldByName('DESCRIPCION').AsString :=
    UpperCase(DataSet.FieldByName('DESCRIPCION').AsString);
  if DataSet.FieldByName('STOCK_MINIMO').IsNull then
    DataSet.FieldByName('STOCK_MINIMO').AsInteger := 10;
end;

end.
