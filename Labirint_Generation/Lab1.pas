unit Lab1;

{
http://ilay.org/yann/articles/maze/

Méthode exhaustive
  On part d'un labyrinthe dont toutes les portes sont fermées.
  Chaque cellule contient une variable booléenne « état » qui indique si la
  cellule est rattachée au labyrinthe ou non.
  Toutes les variables sont à faux (0).
  On choisi une cellule, on met son état à vrai (1).
  Puis on regarde quels sont les cellules voisines disponibles et dont l'état
  est à 0 et on stocke la position en cours.
  S'il y a au moins une possibilité, on en choisi une au hasard, on ouvre la
  porte et on recommence avec la nouvelle cellule.
  S'il n'y en pas, on revient à la case précédente et on recommence.
  Quand on est revenu à la case départ et qu'il n'y a plus de possibilités,
  le labyrinthe est terminé.
  -----------------------------------------------------------------------------
  Dans le programme qui suit, j'ai choisi d'avoir des éléments portes ayant la
  même dimension que les éléments cellules.
  Au départ, le tableau est rempli de portes, puis on installe les cellules qui
  ont pour indices ligne et colonne les valeurs impaires. Elles contiennent
  la valeur 1. Les murs ont la valeur 9 et les éléments du mur extérieur
  prennent la valeur 255 pour éviter les débordements.

La suite est expliquée dans les commentaires.
}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls,
  Lab2;

type
  TForm1 = class(TForm)
    Laby: TImage;
    BtGo: TButton;
    BtChemin: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Initialise;
    procedure BtGoClick(Sender: TObject);
    procedure CelluleSuite;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtCheminClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;
  tbcl : array[0..32,0..22] of byte;  // le labyrinthe

implementation

{$R *.dfm}

const
  xm = 32;
  ym = 22;
var
  pn,pv,pc : TBitmap;
  tbpr : array of TPoint;             // table des pointeurs de cellule
  nbpr : integer;                     // nbre d'entrées dans la table
  ptec : TPoint;                      // pointeur de la cellule en cours
  porte : array[1..4] of byte;        // sert à tester les portes

procedure Trace(num : integer);
begin
  Showmessage(IntToStr(num));
end;

procedure Trac2(n1,n2 : integer);
begin
  Showmessage(IntToStr(n1)+','+IntToStr(n2));
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Randomize;
  pn := TBitmap.Create;
  pn.LoadFromFile('PN.bmp');   // bitmap mur
  pv := TBitmap.Create;
  pv.LoadFromFile('PV.bmp');   // bitmap cellule
  pc := TBitmap.Create;
  pc.LoadFromFile('PC.bmp');
  lesCases := TAStarList.Create;
  leChemin := TAStarList.Create;
  macase := TAStarcell.Create;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  pn.Free;
  pv.Free;
  pc.Free;
  macase.Free;
  leChemin.Free;
  lesCases.Free;
end;

procedure TForm1.Initialise;
var  cl,lg,x,y : integer;
begin
  for cl := 0 to 32 do         // définition du mur extérieur
  begin
    tbcl[cl,0] := 255;
    tbcl[cl,22] := 255;
  end;
  for lg := 0 to 22 do
  begin
    tbcl[0,lg] := 255;
    tbcl[32,lg] := 255;
  end;
  y := 0;
  for lg := 0 to 22 do         // remplissage de la grille avec les portes
  begin
    x := 0;
    for cl := 0 to 32 do
    begin
     laby.Canvas.Draw(x,y,pn);
     inc(x,25);
    end;
    inc(y,25);
  end;
  for lg := 1 to 21 do        // initialisation du tableau labyrinthe
    for cl := 1 to 31 do
    begin
      tbcl[cl,lg] := 9;                             // porte             
      if Odd(lg) and Odd(cl) then tbcl[cl,lg] := 1; // cellule fermée
    end;
  for lg := 1 to 21 do
    for cl := 1 to 31 do                   // tracé des cellules
      if tbcl[cl,lg] = 1 then laby.Canvas.Draw(cl*25,lg*25,pv);
end;

procedure TForm1.BtGoClick(Sender: TObject);  // début du tracé du labyrinthe
var cl,lg : integer;
begin
  Initialise;
// Choix des coordonnées de la première cellule
  repeat
    cl := Random(31)+1;
  until Odd(cl);
  repeat
    lg := Random(21)+1;
  until Odd(lg);
// Init de la table des pointeurs (array dynamique)
  nbpr := 1;                                     
  SetLength(tbpr,nbpr);
  tbpr[0].X := cl;                     // chargement des coordonnées
  tbpr[0].Y := lg;                     // de la première cellule
  laby.Canvas.Draw(25*cl,25*lg,pv);    // tracé de la 1ère cellule
  tbcl[cl,lg] := 0;                    // ouverture 1ère cellule
  ptec := tbpr[0];                     // chargement du pointeur en cours
  while nbpr > 0 do CelluleSuite;      // exécution jusqu'au retour du pointeur
end;      // sur la première cellule et que toutes ses portes soient ouvertes.

procedure TForm1.CelluleSuite;         // élaboration du labyrinthe
var  i,nb,np  : byte;
     cl,lg : integer;
begin
  cl := ptec.X;
  lg := ptec.Y;
// rescencement des portes fermées
  for i := 1 to 4 do                // Nord, Est, Sud, Ouest
  begin
    porte[i] := 0;
    case i of
      1 : if tbcl[cl,lg-1] = 9 then                   // porte fermée
            if tbcl[cl,lg-2] = 1 then porte[i] := 1   // et cellule libre
            else porte[i] := 0;
      2 : if tbcl[cl+1,lg] = 9 then
            if tbcl[cl+2,lg] = 1 then porte[i] := 1
            else porte[i] := 0;
      3 : if tbcl[cl,lg+1] = 9 then
            if tbcl[cl,lg+2] = 1 then porte[i] := 1
            else porte[i] := 0;
      4 : if tbcl[cl-1,lg] = 9 then
            if tbcl[cl-2,lg] = 1 then porte[i] := 1
            else porte[i] := 0;
    end;
  end;
// pour choisir au hasard une porte, on tire pour chaque porte fermée une
// valeur entre 1 et 5.
  for i := 1 to 4 do
    if porte[i] > 0 then porte[i] := Random(5)+1;
// on choisit la porte ayant la plus grande valeur
  nb := 0;
  np := 0;
  for i := 1 to 4 do
    if porte[i] > np then     // si la valeur de la porte est supérieur à
    begin                     // la valeur stockée "np", on stocke la
      nb := i;                // nouvelle valeur ainsi que le numéro de
      np := porte[i];         // la porte "nb".
    end;
  if nb > 0 then    // si au moins une porte est disponible...
  begin
    case nb of      // en fonction de la direction, on modifie le pointeur
      1 : begin     // Nord
            dec(lg);
            tbcl[cl,lg] := 0;            // on efface le mur dans le tableau...
            laby.Canvas.Draw(cl*25,lg*25,pv);  // et à l'écran
            dec(lg);
            tbcl[cl,lg] := 0;            // on ouvre la cellule
          end;
      2 : begin     // Est
            inc(cl);
            tbcl[cl,lg] := 0;
            laby.Canvas.Draw(cl*25,lg*25,pv);
            inc(cl);
            tbcl[cl,lg] := 0;
          end;
      3 : begin      // Sud
            inc(lg);
            tbcl[cl,lg] := 0;
            laby.Canvas.Draw(cl*25,lg*25,pv);
            inc(lg);
            tbcl[cl,lg] := 0;
          end;
      4 : begin     // Ouest
            dec(cl);
            tbcl[cl,lg] := 0;
            laby.Canvas.Draw(cl*25,lg*25,pv);
            dec(cl);
            tbcl[cl,lg] := 0;
          end;
    end;
    inc(nbpr);                 // on enregistre la nouvelle cellule dans
    SetLength(tbpr,nbpr);      // la table des pointeurs
    tbpr[nbpr-1].X := cl;
    tbpr[nbpr-1].Y := lg;
    ptec := tbpr[nbpr-1];      // et on met à jour le pointeur en cours
  end
  else    // ...si aucune porte disponible, on revient à la cellule précédente
    begin
      dec(nbpr);
      ptec := tbpr[nbpr-1];
    end;
end;

procedure TForm1.BtCheminClick(Sender: TObject);
var  chm : array of TPoint;
     tdep,tarv : TPoint;
     i,nb,px,py : integer;
begin
  laby.Canvas.Brush.Color := clBlue;
  laby.Canvas.FillRect(Rect(25,25,50,50));  // tracé de l'entrée
  laby.Canvas.Brush.Color := clYellow;
  laby.Canvas.FillRect(Rect(31*25,21*25,31*25+25,21*25+25)); // et de la sortie
  laby.Repaint;
  tdep.X := 1;
  tdep.Y := 1;
  tarv.X := 31;
  tarv.Y := 21;
  nb := -1;
  if CheminOk(tdep,tarv) then
  begin
    SetLength(chm,High(chemin)+1);
    for i := High(chemin) downto 0 do
    begin
      chm[i] := chemin[i];
      inc(nb);
    end;
    for i := 0 to nb do
    begin
      px := chm[i].X * 25 + 1;
      py := chm[i].Y * 25 + 1;
      Laby.Canvas.Draw(px,py,pc);
    end;
  end
  else Trace(High(chm));
end;

end.
