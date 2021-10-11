unit Lab2;

// Les classes TAStarCell et TAStarList ont été fournies par NeoDelphi.
// L'algorihtme correspondant a été modifié pour les besoins de la cause.
// Les noms des procédures ont donc été changés, pour éviter toute confusion.

interface

uses Windows, SysUtils, Classes, Graphics, ExtCtrls, Controls, Dialogs;


type
  // Donnée d'une case pour le calcul du plus court chemin
  // On utilise une classe pour permettre de travailler plus facilement avec
  // des pointeurs et pouvoir faire pointer la cellule vers son parent.
  // Le parent est très important car c'est celui-ci qui permet de remonter le
  // chemin une fois l'algorihme terminé.
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
  // Les données sont stockées sous forme de liste chainée.
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
  leChemin : TAStarList;    // liste fermée
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

// Récupération des données utiles : position et cout
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
    depart := macase.position; // d'acquérir la nouvelle
    inc(nbca);
    SetLength(chemin,nbca);
    chemin[nbca-1] := depart;           
    macase := macase.parent;
  end;
end;

//******************************************************************************
// Début de l'algorithme de recherche du plus court chemin
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
  // On crée la cellule de départ
  curcell := TAStarCell.Create;
  curcell.position := depart;
  curcell.calcCost();
  // On ajoute la cellule de départ à la liste fermée
  leChemin.add(curcell);
  // Tant que on n'est pas arrivé au point d'arrivée ou que la liste ouverte
  // n'est pas vide on continu à chercher.
  stop := false;
  while stop = false do
  begin
    // On effectue la recherche à partir de la case courante
    AjouteCase(curcell, Point(curcell.position.X, curcell.position.Y-1));
    AjouteCase(curcell, Point(curcell.position.X, curcell.position.Y+1));
    AjouteCase(curcell, Point(curcell.position.X-1, curcell.position.Y));
    AjouteCase(curcell, Point(curcell.position.X+1, curcell.position.Y));
    // On cherche la prochaine case depuis lauqelle effectué la recherche :
    // celle qui à le plus faible cout.
    // Si la liste ouverte est vide on peut pas et cela signifie qu'il n'y a
    // aucun trajet possible.
    if not lesCases.isFree() then
    begin
      nextcell := lesCases.getSmaller();
      // Si on est arrivé on arrête.
      // Ce test doit etre fait avant de retirer la case courante de la liste ouverte.
      if (nextcell.position.Y = but.Y) and (nextcell.position.X = but.X) then
      begin
        stop := true;
        RecUtiles;
        Result := true;
      end
      else
        begin
        // On retire la prochaine case de la liste ouverte et on l'ajoute à la liste fermée.
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
// Ajoute la cellule si elle n'y est pas déjà dans la liste ouverte et renvoie
// le prix de trajet.
//******************************************************************************
procedure AjouteCase(parent: TAStarCell; position: TPoint);
var
  cell: TAStarCell;
  tmpcell: TAStarCell;
begin
  // On vérifie que la cellule ne sort pas de la carte et que l'on ne tombe
  // pas sur un mur
  // Il faut également que la cellule ne soit pas dans la liste fermée
  if (position.X >= 0) and (position.X < nbCasesX)
  and(position.Y >= 0) and (position.Y < nbCasesY)
  and(tbcl[position.X, position.Y] = 0)
  and(leChemin.get(position) = nil) then
  begin
    // On récupère la cellule
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
       // On ajoute la cellule à la liste ouverte
      lesCases.add(cell);
    end
    else
     // Si la cellule est déjà dans la liste :
     // on crée une cellule temporaire à la même position et on calcule le cout.
     // Si ce cout est plus faible c'est que l'on a trouvé un chemin plus
     // court pour arriver à la même cellule, et on modifira donc les données
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
// Initialise les pointeurs de liste chainée à nil c-a-d qu'ils ne pointent sur rien.
//******************************************************************************
constructor TAStarCell.Create();
begin
  parent := nil;
  llprevious := nil;
  llnext := nil;
end;

//******************************************************************************
// Calcul du prix de déplacement
//******************************************************************************
procedure TAStarCell.calcCost();
begin
  // Le prix pour venir est le prix pour venir du parent + 1
  if parent<>nil then costfrom := parent.costfrom + 1
  else costfrom := 0;
  // Le prix pour y aller est un calcul approximatif qui ne prend pas en compte
  // les données de la carte.
  // Ici c'est la distance du plus court chemin si il n'y a pas de murs.
  costto := abs( but.Y - position.Y )+ abs(but.X - position.X);
  cost := costfrom + costto;
end;

//******************************************************************************
// Constructeur du TAStarList.
// On initialise les pointeurs de premier et dernier éléments à nil.
//******************************************************************************
constructor TAStarList.Create();
begin
  first := nil;
  last := nil;
end;

//******************************************************************************
// Ajout d'un élément passé en paramètre à la liste chainée.
//******************************************************************************
procedure TAStarList.add(element: TAStarCell);
begin
  // Si la liste chainée n'est pas vide
  if first <> nil then
  begin
    // On fait pointer le dernier élément sur le nouveau
    last.llnext := element;
    // On fait pointer le nouvel élément sur le dernier
    element.llprevious := last;
    // On ne met pas d'éléments suivants
    element.llnext := nil;
    // On fait pointer last sur element
    last := element;
  end
  else
    begin
      // L'élément est a la fois le premier et le dernier
      first := element;
      last := element;
    end;
end;

//******************************************************************************
// Supprime de la liste chainée l'élément
//******************************************************************************
procedure TAStarList.del(element: TAStarCell);
begin
  // On vérifi si il y a un élément avant
  if element.llprevious <> nil then
  begin
    // On fait pointer le suivant du précédent sur le suivant du courant (euh ?!)
    element.llprevious.llnext := element.llnext;
  end
  else
  // Sinon c'est qu'il s'agit du premier élément
    begin
      first := element.llnext;
    end;

  // On regarde si l'élément à un élément suivant
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
  // Par défaut le résultat est nil
  _result := nil;
  current := first;
  // On fait pointer le current sur le premier élément de la liste
  while (_result = nil) and (current <> nil) do
  begin
    // On regarde si la position de la cellule correspond à celle demandée
    if (current.position.X = position.X) and (current.position.Y = position.Y) then
    begin
      _result := current;
    end
    else
      begin
        // Si la cellule n'est pas celle que l'on cherche on passe à la suivante
        current := current.llnext;
      end;
    end;
  // On retourne le résultat
  get := _result;
end;

//******************************************************************************
// Renvoie la cellule qui a le plus faible cout.
// Pour la recherche du plus court chemin il faut regarder la liste en
// commançant par le dernier élément
// (correspond à l'élément qui viend d'etre ajouté).
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
  // On fait pointer le current sur le premier élément de la liste
  while (current <> nil) do
  begin
    if (current.cost < smaller) or (smaller = -1) then
    begin
      smaller := current.cost;
      smaller_cell := current;
    end;
    current := current.llprevious;
  end;
  // On retourne le résultat
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
// Efface la liste en libérant la mémoire pour chaque AStarCell
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
