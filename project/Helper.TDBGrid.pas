unit Helper.TDBGrid;

interface

uses
  System.Classes,
  System.Math,
  Data.DB,
  Vcl.DBGrids;

type
  TDBGridHelper = class helper for TDBGrid
  public
    function AutoSizeColumns(const MaxRows: Integer = 25): Integer;
  end;

implementation

function TDBGridHelper.AutoSizeColumns(const MaxRows: Integer = 25): Integer;
var
  DataSet: TDataSet;
  Bookmark: TBookmark;
  Count, i: Integer;
  ColumnsWidth: array of Integer;
begin
  SetLength(ColumnsWidth, Self.Columns.Count);
  for i := 0 to Self.Columns.Count - 1 do
    if Self.Columns[i].Visible then
      ColumnsWidth[i] := Self.Canvas.TextWidth
        (Self.Columns[i].title.Caption + '   ')
    else
      ColumnsWidth[i] := 0;
  if Self.DataSource <> nil then
    DataSet := Self.DataSource.DataSet
  else
    DataSet := nil;
  if (DataSet <> nil) and DataSet.Active then
  begin
    Bookmark := DataSet.GetBookmark;
    DataSet.DisableControls;
    try
      Count := 0;
      DataSet.First;
      while not DataSet.Eof and (Count < MaxRows) do
      begin
        for i := 0 to Self.Columns.Count - 1 do
          if Self.Columns[i].Visible then
            ColumnsWidth[i] := System.Math.Max(ColumnsWidth[i],
              Self.Canvas.TextWidth(Self.Columns[i].Field.Text + '   '));
        Inc(Count);
        DataSet.Next;
      end;
    finally
      DataSet.GotoBookmark(Bookmark);
      DataSet.FreeBookmark(Bookmark);
      DataSet.EnableControls;
    end;
  end;
  Count := 0;
  for i := 0 to Self.Columns.Count - 1 do
    if Self.Columns[i].Visible then
    begin
      Self.Columns[i].Width := ColumnsWidth[i];
      Inc(Count, ColumnsWidth[i]);
    end;
  Result := Count - Self.ClientWidth;
end;

end.
