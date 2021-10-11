program Laby;

uses
  Forms,
  Lab1 in 'Lab1.pas' {Form1},
  Lab2 in 'Lab2.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
