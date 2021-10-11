unit Lab2;

// Les classes TAStarCell et TAStarList ont �t� fournies par NeoDelphi.
// L'algorihtme correspondant a �t� modifi� pour les besoins de la cause.
// Les noms des proc�dures ont donc �t� chang�s, pour �viter toute confusion.

interface

uses Windows, SysUtils, Classes, Graphics, ExtCtrls, Controls, Dialogs;


type
  // Donn�e d'une case pour le calcul du plus court chemin
  // On utilise une classe pour permettre de travailler plus facilement avec
  // des pointeurs et pouvoir faire pointer la cellule vers son parent.
  // Le parent est tr�s important car c'est celui-ci qui permet de remonter le
  // chemin une fois l'algorihme termin�.
  TAStarCell = class
    position: TPoint;
    costfrom: integer;
    costto: integer;
    cost: integer;
    parent: TAStarCell;
    llprevious: TAStarCell;
    llnext: TAStarCell;

    constructor Create;
    procedure calcCost;
  end;

  // Pile pour avoir les liste de cellules pour le calcul du plus court chemin.
  // Les donn�es sont stock�es sous forme de liste chain�e.
  TAStarList = class
    first: TAStarCell;
    last: TAStarCell;

    constructor Create;
    procedure add(element: TAStarCell);
    procedure del(element: TAStarCell);
    procedure clear;
    function get(position: TPoint ): TAStarCell;
    function getSmaller: TAStarCell;
    function isFree: boolean;
  end;

var
  depart : TPoint;
  but : TPoint;
  lesCases : TAStarList;    // liste ouverte
  leChemin : TAStarList;    // liste ferm�e
  macase : TAStarcell;
  propos : TPoint;
  cout : integer;
  nbca : integer;
  route,
  chemin : array of Tpoint;

const nbCasesX = 32;
      nbCasesY = 22;

procedure TracePt(tp : TPoint);
procedure RecUtiles;
function CheminOk(dep,arv : TPoint) : boolean;
procedure AjouteCase(parent: TAStarCell; position: TPoint);

implementation

uses Lab1;

procedure TracePt(tp : TPoint);
begin
  with tp do
    Showmessage(inttostr(X)+' - '+inttostr(Y));
end;

// R�cup�ration des donn�es utiles : position et cout
procedure RecUtiles;
var  i,n : integer;
begin
  nbca := 1;
  SetLength(chemin,nbca);
  chemin[0] := but;
  cout := leChemin.last.costfrom + 1;
  macase := leChemin.last;
  while macase.parent <> nil do
  begin
    propos := depart;   // on stocke la position avant de
    depart := macase.position; // d'acqu�rir la nouvelle
    inc(nbca);
    SetLength(chemin,nbca);
    chemin[nbca-1] := depart;           
    macase := macase.parent;
  end;
end;

//******************************************************************************
// D�but de l'algorithme de recherche du plus court chemin
//******************************************************************************
function CheminOk(dep,arv : TPoint) : boolean;
var
  curcell: TAStarCell;
  nextcell: TAStarCell;
  stop: boolean;
begin
  Result := false;
  depart := dep;
  but := arv;
  // On efface les listes
  lesCases.clear();
  leChemin.clear();
  // On cr�e la cellule de d�part
  curcell := TAStarCell.Create;
  curcell.position := depart;
  curcell.calcCost();
  // On ajoute la cellule de d�part � la liste ferm�e
  leChemin.add(curcell);
  // Tant que on n'est pas arriv� au point d'arriv�e ou que la liste ouverte
  // n'est pas vide on continu � chercher.
  stop := false;
  while stop = false do
  begin
    // On effectue la recherche � partir de la case courante
    AjouteCase(curcell, Point(curcell.position.X, curcell.position.Y-1));
    AjouteCase(curcell, Point(curcell.position.X, curcell.position.Y+1));
    AjouteCase(curcell, Point(curcell.position.X-1, curcell.position.Y));
    AjouteCase(curcell, Point(curcell.position.X+1, curcell.position.Y));
    // On cherche la prochaine case depuis lauqelle effectu� la recherche :
    // celle qui � le plus faible cout.
    // Si la liste ouverte est vide on peut pas et cela signifie qu'il n'y a
    // aucun trajet possible.
    if not lesCases.isFree() then
    begin
      nextcell := lesCases.getSmaller();
      // Si on est arriv� on arr�te.
      // Ce test doit etre fait avant de retirer la case courante de la liste ouverte.
      if (nextcell.position.Y = but.Y) and (nextcell.position.X = but.X) then
      begin
        stop := true;
        RecUtiles;
        Result := true;
      end
      else
        begin
        // On retire la prochaine case de la liste ouverte et on l'ajoute � la liste ferm�e.
          lesCases.del(nextcell);
          leChemin.add(nextcell);
        // On met la prochaine case dans curcell.
          curcell := nextcell;
       end;
    end
    else
      stop := true;
  end;
end;

//******************************************************************************
// Ajoute la cellule si elle n'y est pas d�j� dans la liste ouverte et renvoie
// le prix de trajet.
//******************************************************************************
procedure AjouteCase(parent: TAStarCell; position: TPoint);
var
  cell: TAStarCell;
  tmpcell: TAStarCell;
begin
  // On v�rifie que la cellule ne sort pas de la carte et que l'on ne tombe
  // pas sur un mur
  // Il faut �galement que la cellule ne soit pas dans la liste ferm�e
  if (position.X >= 0) and (position.X < nbCasesX)
  and(position.Y >= 0) and (position.Y < nbCasesY)
  and(tbcl[position.X, position.Y] = 0)
  and(leChemin.get(position) = nil) then
  begin
    // On r�cup�re la cellule
    cell := lesCases.get(position);
    // Si la cellule n'est pas encore dans la liste ouverte
    if cell = nil then
    begin
      cell := TAStarCell.Create;
      cell.position := position;
      // On met le parent pour savoir de quelle cellule on viend
      cell.parent := parent;
       // On fait le calcul du prix
      cell.calcCost();
       // On ajoute la cellule � la liste ouverte
      lesCases.add(cell);
    end
    else
     // Si la cellule est d�j� dans la liste :
     // on cr�e une cellule temporaire � la m�me position et on calcule le cout.
     // Si ce cout est plus faible c'est que l'on a trouv� un chemin plus
     // court pour arriver � la m�me cellule, et on modifira donc les donn�es
     // de la cellule pour prendre en compte le nouveau chemin : on change
     // le parent et le cout.
       begin
         tmpcell := TAStarCell.Create;
         tmpcell.position := position;
         tmpcell.parent := parent;
         tmpcell.calcCost;
         if tmpcell.costfrom < cell.costfrom then
         begin
           cell.parent := parent;
           cell.calcCost();
         end;
         tmpcell.Free;
       end;
  end;
end; 

//******************************************************************************
// Constructeur AStarCell.
// Initialise les pointeurs de liste chain�e � nil c-a-d qu'ils ne pointent sur rien.
//******************************************************************************
constructor TAStarCell.Create();
begin
  parent := nil;
  llprevious := nil;
  llnext := nil;
end;

//******************************************************************************
// Calcul du prix de d�placement
//******************************************************************************
procedure TAStarCell.calcCost();
begin
  // Le prix pour venir est le prix pour venir du parent + 1
  if parent<>nil then costfrom := parent.costfrom + 1
  else costfrom := 0;
  // Le prix pour y aller est un calcul approximatif qui ne prend pas en compte
  // les donn�es de la carte.
  // Ici c'est la distance du plus court chemin si il n'y a pas de murs.
  costto := abs( but.Y - position.Y )+ abs(but.X - position.X);
  cost := costfrom + costto;
end;

//******************************************************************************
// Constructeur du TAStarList.
// On initialise les pointeurs de premier et dernier �l�ments � nil.
//******************************************************************************
constructor TAStarList.Create();
begin
  first := nil;
  last := nil;
end;

//******************************************************************************
// Ajout d'un �l�ment pass� en param�tre � la liste chain�e.
//******************************************************************************
procedure TAStarList.add(element: TAStarCell);
begin
  // Si la liste chain�e n'est pas vide
  if first <> nil then
  begin
    // On fait pointer le dernier �l�ment sur le nouveau
    last.llnext := element;
    // On fait pointer le nouvel �l�ment sur le dernier
    element.llprevious := last;
    // On ne met pas d'�l�ments suivants
    element.llnext := nil;
    // On fait pointer last sur element
    last := element;
  end
  else
    begin
      // L'�l�ment est a la fois le premier et le dernier
      first := element;
      last := element;
    end;
end;

//******************************************************************************
// Supprime de la liste chain�e l'�l�ment
//******************************************************************************
procedure TAStarList.del(element: TAStarCell);
begin
  // On v�rifi si il y a un �l�ment avant
  if element.llprevious <> nil then
  begin
    // On fait pointer le suivant du pr�c�dent sur le suivant du courant (euh ?!)
    element.llprevious.llnext := element.llnext;
  end
  else
  // Sinon c'est qu'il s'agit du premier �l�ment
    begin
      first := element.llnext;
    end;

  // On regarde si l'�l�ment � un �l�ment suivant
  if element.llnext <> nil then
  begin
    element.llnext.llprevious := element.llprevious;
  end
  else
    begin
      last := element.llprevious;
   end;
end;

//******************************************************************************
// Renvoie la cellule en fonction de la position, renvoie nil si elle n'existe pas
//******************************************************************************
function TAStarList.get(position: TPoint): TAStarCell;
var
  _result: TAStarCell;
  current: TAStarCell;
begin
  // Par d�faut le r�sultat est nil
  _result := nil;
  current := first;
  // On fait pointer le current sur le premier �l�ment de la liste
  while (_result = nil) and (current <> nil) do
  begin
    // On regarde si la position de la cellule correspond � celle demand�e
    if (current.position.X = position.X) and (current.position.Y = position.Y) then
    begin
      _result := current;
    end
    else
      begin
        // Si la cellule n'est pas celle que l'on cherche on passe � la suivante
        current := current.llnext;
      end;
    end;
  // On retourne le r�sultat
  get := _result;
end;

//******************************************************************************
// Renvoie la cellule qui a le plus faible cout.
// Pour la recherche du plus court chemin il faut regarder la liste en
// comman�ant par le dernier �l�ment
// (correspond � l'�l�ment qui viend d'etre ajout�).
//******************************************************************************
function TAStarList.getSmaller(): TAStarCell;
var
  smaller: integer;
  smaller_cell: TAStarCell;
  current: TAStarCell;
begin
  smaller := -1;
  smaller_cell := nil;
  current := last;
  // On fait pointer le current sur le premier �l�ment de la liste
  while (current <> nil) do
  begin
    if (current.cost < smaller) or (smaller = -1) then
    begin
      smaller := current.cost;
      smaller_cell := current;
    end;
    current := current.llprevious;
  end;
  // On retourne le r�sultat
  getSmaller := smaller_cell;
end;

//******************************************************************************
// Renvoie true si la liste est vide
//******************************************************************************
function TAStarList.isFree(): boolean;
begin
  isFree := first = nil;
end;

//******************************************************************************
// Efface la liste en lib�rant la m�moire pour chaque AStarCell
//******************************************************************************
procedure TAStarList.clear();
var
  current: TAStarCell;
  next: TAStarCell;
begin
  current := first;
  while current<>nil do
  begin
    next := current.llnext;
    current.Free;
    current := next;
  end;
  first := nil;
  last := nil;
end;

//------------------------------------------------------------------------------

end.
