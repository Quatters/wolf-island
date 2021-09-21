uses GraphABC;

const WIDTH = 970; // ширина окна
const HEIGHT = 640; // высота окна
const SIZE = 600; // длина и ширина игрового поля 
const CELLS = 20; // количество клеток в длину и ширину 
const SCALE = SIZE div CELLS; // размер клетки на поле

type Direction = (N, S, W, E, NE, NW, SE, SW, NULL); 
type WolfSex = (M, F);

function RandomDir(): Direction;
begin
  var dir: Direction;
  case random(9) of
    0: dir := NULL;
    1: dir := N;
    2: dir := S;
    3: dir := W;
    4: dir := E;
    5: dir := NE;
    6: dir := NW;
    7: dir := SE;
    8: dir := SW;
  end;
  RandomDir := dir;
end;

function NumToDir(num: integer): Direction;
begin
  var dir: Direction;
  case num of
    1: dir := N;
    2: dir := S;
    3: dir := E;
    4: dir := W;
    5: dir := NE;
    6: dir := NW;
    7: dir := SE;
    8: dir := SW;
    else dir := NULL;
  end;
  NumToDir := dir;
end;

function RandomSex(): WolfSex;
begin
  var x := random(2);
  var sex: WolfSex;
  if x = 0 then sex := M
  else sex := F;
  RandomSex := sex;
end;

type
World = class
  
private
  static speed: integer := 3;
  
public
  static firstCellCoords: integer;
  static firstCellCenterCoords: integer;
  
  constructor();
  begin
    SetWindowSize(WIDTH, HEIGHT);
    SetWindowTitle('Волчий Остров');
    SetWindowTop(20);
    SetWindowLeft(20);
    
    // отрисовка мира
    var pic := new Picture('bg.png');
    var indent: integer := (HEIGHT - SIZE) div 2;
    pic.Draw(indent, indent);
    firstCellCoords := indent + 3;
    firstCellCenterCoords := indent + SCALE div 2;
  end;

  static procedure SetSpeed(sp: integer);
  begin
    if (sp >= 1) and (sp <= 3) then
      speed := sp
  end;
  
  static function GetSpeed(): integer;
  begin
    GetSpeed := speed;
  end;
  
  static function DelayFromSpeed(): integer;
  begin
    case speed of 
      1: DelayFromSpeed := 50;
      2: DelayFromSpeed := 2;
      3: DelayFromSpeed := 0;
    end;
  end;
  
  static function GetCellCenterX(u: integer): integer;
  begin
    GetCellCenterX := firstCellCenterCoords + (u - 1)*SCALE + 4;
  end;
  
  static function GetCellCenterY(v: integer): integer;
  begin
    GetCellCenterY := firstCellCenterCoords + (v - 1)*SCALE + 4;
  end;
  
  static function CanPlace(u, v: integer): boolean;
  begin
    if GetPixel(GetCellCenterX(u), GetCellCenterY(v)) = GetPixel(1, 1) then CanPlace := true // сравнение с цветом нейтральной клетки
    else CanPlace := false;
  end;
  
end;

Entity = abstract class
  
protected
  none: Picture := new Picture('none.png');
  x, y: integer; // фактические координаты объекта
  u, v: integer; // координаты клетки объекта в диапазоне [1; 20]
  
  procedure Move(dir: Direction); abstract;
 
  procedure SetX(u: integer);
  begin
    x := World.firstCellCoords + (u - 1)*SCALE;
    self.u := u;
  end;
  
  procedure SetY(v: integer);
  begin
    y := World.firstCellCoords + (v - 1)*SCALE;
    self.v := v;
  end;
  
  function GetUFromDirection(dir: Direction): integer;
  begin
    var u: integer;
    case dir of
      E, NE, SE: u := self.u + 1;
      W, NW, SW: u := self.u - 1;
      else u := self.u;
    end;
    GetUFromDirection := u;
  end;
  
  function GetVFromDirection(dir: Direction): integer;
  begin
    var v: integer;
    case dir of
      N, NE, NW: v := self.v - 1;
      S, SE, SW: v := self.v + 1;
      else v := self.v;
    end;
    GetVFromDirection := v;
  end;
  
public
  function CanMove(dir: direction): boolean;
  begin
    CanMove := false;
    var u := GetUFromDirection(dir);
    var v := GetVFromDirection(dir);
    var x := World.GetCellCenterX(u);
    var y := World.GetCellCenterY(v);
    if GetPixel(x, y) = GetPixel(1, 1) then begin // сравнение с цветом нейтральной клетки
      case dir of
        N: begin
          if (v >= 1) then
            CanMove := true;
        end;
        S: begin
          if (v <= 20) then
            CanMove := true;
        end;
        W: begin
          if (u >= 1) then
            CanMove := true;
        end;
        E: begin
          if (u <= 20) then
            CanMove := true;
        end;
        NE: begin
          if (v >= 1) and (u <= 20) then
            CanMove := true;
        end;
        NW: begin
          if (v >= 1) and (u >= 1) then
            CanMove := true;
        end;
        SE: begin
          if (v <= 20) and (u <= 20) then
            CanMove := true;
        end;
        SW: begin
          if (v <= 20) and (u >= 1) then
            CanMove := true;
        end;
      end;
    end;
  end;
  
  procedure Play();
  begin
    Move(RandomDir());
    Sleep(World.DelayFromSpeed());
  end;

  function GetU(): integer;
  begin
    GetU := u;
  end;
  
  function GetV(): integer;
  begin
    GetV := v;
  end;

end;

Rabbit = class(Entity)
  
private
  pic := new Picture('rabbit.png');
  
public
  static count: integer := 0;

  constructor(u, v: integer);
  begin
    SetX(u);
    SetY(v);
    pic.Draw(x, y);
    self.u := u;
    self.v := v;
    count += 1;
  end;
  
  constructor(rbt: Rabbit; dir: Direction);
  begin
    SetX(GetUFromDirection(rbt, dir));
    SetY(GetVFromDirection(rbt, dir));
    pic.Draw(x, y);
    u := GetUFromDirection(rbt, dir);
    v := GetVFromDirection(rbt, dir);
    count += 1;
  end;
 
public  
  function GetRabbit(u, v: integer): Rabbit;
  begin
    var rbt := self;
    if (rbt.u = u) and (rbt.v = v) then
      GetRabbit := rbt
    else
      GetRabbit := nil;
  end;

  function GetUFromDirection(rbt: Rabbit; dir: Direction): integer;
  begin
    var u: integer;
    case dir of
      E, NE, SE: u := rbt.u + 1;
      W, NW, SW: u := rbt.u - 1;
      else u := rbt.u;
    end;
    GetUFromDirection := u;
  end;
  
  function GetVFromDirection(rbt: Rabbit; dir: Direction): integer;
  begin
    var v: integer;
    case dir of
      N, NE, NW: v := rbt.v - 1;
      S, SE, SW: v := rbt.v + 1;
      else v := rbt.v;
    end;
    GetVFromDirection := v;
  end;

  procedure Move(dir: Direction); override;
  begin    
    case (dir) of 
      N: begin
        if CanMove(N) then begin
          none.Draw(x, y);
          SetY(v - 1);
        end;
      end;
      S: begin
        if CanMove(S) then begin
          none.Draw(x, y);
          SetY(v + 1);
        end;
      end;
      W: begin
        if CanMove(W) then begin
          none.Draw(x, y);
          SetX(u - 1);
        end;
      end;
      E: begin
        if CanMove(E) then begin
          none.Draw(x, y);
          SetX(u + 1);
        end;
      end;
      NE: begin
        if CanMove(NE) then begin
          none.Draw(x, y);
          SetY(v - 1);
          SetX(u + 1);
        end;
      end;
      NW: begin
        if CanMove(NW) then begin
          none.Draw(x, y);
          SetY(v - 1);
          SetX(u - 1);
        end;
      end;
      SE: begin
        if CanMove(SE) then begin
          none.Draw(x, y);
          SetY(v + 1);
          SetX(u + 1);
        end;
      end;
      SW: begin
        if CanMove(SW) then begin
          none.Draw(x, y);
          SetY(v + 1);
          SetX(u - 1);         
        end;
      end;
    end;
    pic.Draw(x, y);
  end;
  
end;

Wolf = class(Entity)

private
  sex: WolfSex;
  pic: Picture;

public
  static count := 0;
  static femaleCount := 0;
  static maleCount := 0;
  points: real := 1.0;
  
  constructor(u, v: integer; sex: WolfSex);
  begin
    if sex = M then begin
      pic := new Picture('wolf_m.png');
      maleCount += 1;
    end
    else begin
      pic := new Picture('wolf_f.png');
      femaleCount += 1;
    end;
    self.sex := sex;
    SetX(u);
    SetY(v);
    pic.Draw(x, y);
    self.u := u;
    self.v := v;
    count += 1;
  end;
  
  function isMale(): boolean;
  begin
    if sex = M then isMale := true
    else isMale := false;
  end;
  
  function FoundFemale(dir: Direction): boolean;
  begin
    var colour: Color := RGB(254, 62, 102); // цвет самки
    if GetPixel(World.GetCellCenterX(GetUFromDirection(dir)), World.GetCellCenterY(GetVFromDirection(dir))) = colour then begin
      FoundFemale := true;
      exit;
    end;
    FoundFemale := false;
  end;
  
  function FoundRabbit(dir: Direction): boolean;
  begin
    var colour: Color := RGB(53, 152, 189); // цвет кролика
    if GetPixel(World.GetCellCenterX(GetUFromDirection(dir)), World.GetCellCenterY(GetVFromDirection(dir))) = colour then begin
      FoundRabbit := true;
      exit;
    end;
    FoundRabbit := false;
  end;
  
  procedure Move(dir: Direction); override;
  begin
    for i: integer := 1 to 8 do begin
      if FoundRabbit(NumToDir(i)) then begin
        dir := NumToDir(i);
        break;
      end;
    end;
    case (dir) of 
      N: begin
        if (FoundRabbit(N)) or (CanMove(N)) then begin
          none.Draw(x, y);
          SetY(v - 1);
        end;
      end;
      S: begin
        if (FoundRabbit(S)) or (CanMove(S)) then begin
          none.Draw(x, y);
          SetY(v + 1);
        end;
      end;
      W: begin
        if (FoundRabbit(W)) or (CanMove(W)) then begin
          none.Draw(x, y);
          SetX(u - 1);
        end;
      end;
      E: begin
        if (FoundRabbit(E)) or (CanMove(E)) then begin
          none.Draw(x, y);
          SetX(u + 1);
        end;
      end;
      NE: begin
        if (FoundRabbit(NE)) or (CanMove(NE)) then begin
          none.Draw(x, y);
          SetY(v - 1);
          SetX(u + 1);
        end;
      end;
      NW: begin
        if (FoundRabbit(NW)) or (CanMove(NW)) then begin
          none.Draw(x, y);
          SetY(v - 1);
          SetX(u - 1);
        end;
      end;
      SE: begin
        if (FoundRabbit(SE)) or (CanMove(SE)) then begin
          none.Draw(x, y);
          SetY(v + 1);
          SetX(u + 1);
        end;
      end;
      SW: begin
        if (FoundRabbit(SW)) or (CanMove(SW)) then begin
          none.Draw(x, y);
          SetY(v + 1);
          SetX(u - 1);         
        end;
      end;
    end;
    pic.Draw(x, y);
  end;
  
end;

type
Node = class

private
  rbt: Rabbit;
  wf: Wolf;
  next: Node;
  
public
  constructor(rbt: Rabbit; next: Node);
  begin
    self.rbt := rbt;
    self.next := next;
  end;
  
  constructor(wf: Wolf; next: Node);
  begin
    self.wf := wf;
    self.next := next;
  end;
end;

var
  rabbitList, wolfList: Node;
  started: boolean := false;
  resetGame: boolean := false;
  pause: boolean := false;

  // изменяемые параметры
  _rabbitMultiplyChance: integer := 20;
  _rabbitCount: integer := 43;
  _wolfCount: integer := 16;

procedure ShowStatistics();
begin
  Brush.Color := clWhite;
  Font.Size := 10;
  FillRectangle(814, HEIGHT - 560, 850, HEIGHT - 540);
  TextOut(816, HEIGHT - 558, World.speed);
  FillRectangle(814, HEIGHT - 538, 850, HEIGHT - 518);
  TextOut(816, HEIGHT - 536, Rabbit.count);
  FillRectangle(800, HEIGHT - 514, 850, HEIGHT - 452);
  TextOut(802, HEIGHT - 514, Wolf.Count);
  TextOut(802, HEIGHT - 492, Wolf.femaleCount);
  TextOut(802, HEIGHT - 470, Wolf.maleCount);
end;

procedure ShowInfo();
begin
  Pen.Width := 1;
  Font.Size := 13;
  Font.Style := fsBold;
  TextOut(756, 45, 'Статистика');
  TextOut(705, HEIGHT - 430, 'Начальные параметры');
  TextOut(756, HEIGHT - 300, 'Управление');
  
  Font.Size := 10;
  Font.Style := fsNormal;
  Font.Color := clBlack;
  TextOut(680, HEIGHT - 558, 'Скорость симуляции: ');
  Font.Color := RGB(46, 132, 164);
  TextOut(680, HEIGHT - 536, 'Популяция кроликов: ');
  Font.Color := clBlack;
  TextOut(680, HEIGHT - 514, 'Популяция волков: ');
  Font.Color := RGB(254, 62, 102);
  TextOut(709, HEIGHT - 492, 'из них волчиц: ');
  Font.Color := RGB(152, 9, 29);
  TextOut(751, HEIGHT - 470, 'волков: ');
  Font.Color := clBlack;
  DrawRectangle(650, 20, 950, 620);
  
  TextOut(680, HEIGHT - 388, '1. Количество кроликов: ' + _rabbitCount);
  TextOut(680, HEIGHT - 366, '2. Количество волков: ' + _wolfCount);
  TextOut(680, HEIGHT - 344, '3. Шанс размножения кроликов: ' + _rabbitMultiplyChance);
  
  TextOut(680, HEIGHT - 258, 'Enter - запуск/перезапуск симуляции');
  TextOut(680, HEIGHT - 228, 'Space - пауза');
  TextOut(680, HEIGHT - 198, 'Стрелки вверх/вниз - изменение');
  TextOut(680, HEIGHT - 176, 'скорости симуляции');
  TextOut(680, HEIGHT - 136, 'Для изменения начальных параметров');
  TextOut(680, HEIGHT - 114, 'остановите игру и нажмите');
  TextOut(680, HEIGHT - 92, 'соответствующую цифру на');
  TextOut(680, HEIGHT - 70, 'клавиатуре.');
  
end;
  
procedure SetEntities();
begin
  var rabbitsQuant := _rabbitCount;
  var wolvesQuant := _wolfCount;
  var rabbitIter: Node;
  var wolfIter: Node;
  var u := random(20) + 1;
  var v := random(20) + 1;
  
  if _rabbitCount <> 0 then begin
    rabbitList := new Node(new Rabbit(random(20) + 1, random(20) + 1), nil);  
    rabbitIter := rabbitList;
  end;
  for i: integer := 1 to rabbitsQuant - 1 do begin
    while not World.CanPlace(u, v) do begin
      u := random(20) + 1;
      v := random(20) + 1;
    end;
    rabbitIter.next := new Node(new Rabbit(u, v), rabbitIter.next);
  end;
  
  if _wolfCount <> 0 then begin
    wolfList := new Node(new Wolf(random(20) + 1, random(20) + 1, RandomSex()), nil);
    wolfIter := wolfList;
  end;
  for i: integer := 1 to wolvesQuant - 1 do begin
    while not World.CanPlace(u, v) do begin
      u := random(20) + 1;
      v := random(20) + 1;
    end;
    wolfIter.next := new Node(new Wolf(u, v, RandomSex()), wolfIter.next);
  end;
end;

procedure CheckWolfPoints(wolfIter: Node);
begin
  if wolfIter.wf.points <= 0 then begin
    if wolfIter.wf.isMale() then Wolf.maleCount -= 1
    else Wolf.femaleCount -= 1;
    Wolf.count -= 1;
    wolfIter.wf.none.Draw(wolfIter.wf.x, wolfIter.wf.y);
    if wolfIter = wolfList then
      wolfList := wolfList.next
    else if wolfIter.next <> nil then begin
      wolfIter.wf := wolfIter.next.wf;
      wolfIter.next := wolfIter.next.next;
    end
    else begin
      var p := wolfList;
      while p.next <> wolfIter do
        p := p.next;
      p.next := p.next.next;
    end;
  end;
end;

procedure RabbitPlay();
begin
  var rabbitIter := rabbitList;
  while (rabbitIter <> nil) do begin
    ShowStatistics();
    if (random(100) < _rabbitMultiplyChance) and (Rabbit.count < 400) then begin
      var randDir := RandomDir();
      if rabbitIter.rbt.CanMove(randDir) then
        rabbitList := new Node(new Rabbit(rabbitIter.rbt, randDir), rabbitList);
    end
    else
      rabbitIter.rbt.Play();
    rabbitIter := rabbitIter.next;
  end;
end;

procedure WolfPlay();
begin
  var wolfIter := wolfList;
  var dir: Direction;
  while (wolfIter <> nil) do begin
    ShowStatistics();
    dir := NULL;
    for i: integer := 1 to 8 do begin
      if wolfIter.wf.FoundRabbit(NumToDir(i)) then begin
        dir := NumToDir(i);
        break;
      end;
    end;
    if dir <> NULL then begin
      wolfIter.wf.Move(dir);
      if (wolfIter.wf.GetU = rabbitList.rbt.GetU) and (wolfIter.wf.GetV = rabbitList.rbt.GetV) then
        rabbitList := rabbitList.next
      else begin
        var eatenRabbit: Node := rabbitList;
        var eatenRabbitPrev: Node := rabbitList;
        while eatenRabbit <> nil do begin
          if (wolfIter.wf.GetU = eatenRabbit.rbt.GetU) and (wolfIter.wf.GetV = eatenRabbit.rbt.GetV) then
            break;
          eatenRabbitPrev := eatenRabbit;
          eatenRabbit := eatenRabbit.next;
        end;
        if eatenRabbit.next <> nil then
          eatenRabbitPrev.next := eatenRabbitPrev.next.next
        else
          eatenRabbitPrev.next := nil;
      end;
      Rabbit.count -= 1;
      if wolfIter.wf.points < 2.3 then
        wolfIter.wf.points += 1;
    end
    else if (wolfIter.wf.isMale()) and (dir = NULL) and (Wolf.count < 400) and (wolfIter.wf.points > 1) then begin
      for i: integer := 1 to 8 do begin
        if (wolfIter.wf.FoundFemale(NumToDir(i))) then begin
          dir := NumToDir(i);
          break;
        end;
      end;
      var k := wolfList;
      while k <> nil do begin
        if (wolfIter.wf.GetUFromDirection(dir) = k.wf.GetU) and (wolfIter.wf.GetVFromDirection(dir) = k.wf.GetV) and not (k.wf.isMale) then
          break;
        k := k.next;
      end;
      if (dir <> NULL) and (k.wf.points > 1) then begin
        wolfIter.wf.Move(dir);
        wolfList := new Node(new Wolf(wolfIter.wf.GetU, wolfIter.wf.GetV, RandomSex()), wolfList);
      end
      else begin
        wolfIter.wf.Play();
        wolfIter.wf.points -= 0.1;
      end;  
    end
    else begin
      wolfIter.wf.Play();
      wolfIter.wf.points -= 0.1;
    end;
    CheckWolfPoints(wolfIter);
    wolfIter := wolfIter.next;
  end;
end;

procedure Play();
begin
  if (Rabbit.count = 0) and (Wolf.count = 0) then
    pause := true;
  ShowStatistics();
  RabbitPlay();
  WolfPlay();
end;

procedure NewGame();
begin
  new World();
  rabbitList := nil;
  wolfList := nil;
  Rabbit.count := 0;
  Wolf.count := 0;
  Wolf.femaleCount := 0;
  Wolf.maleCount := 0;
  SetEntities();
  ShowStatistics();
end;

procedure KeyDown(key: integer);
begin
  case key of
    VK_UP: World.SetSpeed(World.GetSpeed() + 1);
    VK_DOWN: World.SetSpeed(World.GetSpeed() - 1);
    VK_SPACE: if not pause and started then pause := true else if pause then pause := false;
    VK_ENTER: begin
      if started then resetGame := true;
      if not started then started := true;
    end;
  end;
end;

var 
  reading: boolean := false;
  readingType: integer;

procedure ReadingFromKeybord();
begin
  var str: string;
  var res, error: integer;
  readln(str);
  Val(str, res, error);
  if (error = 0) and (res >= 0) then begin
    case readingType of
      1: if res <= 400 - _wolfCount then _rabbitCount := res;
      2: if res <= 400 - _rabbitCount then _wolfCount := res;
      3: if (res >= 0) and (res <= 100) then
          _rabbitMultiplyChance := res;
    end;
  end;
  reading := false;
  resetGame := true;
end;

procedure KeyPressed(key: char);
begin
  Brush.Color := clWhite;
  if not started then begin
    case key of
      '1': begin
          FillRectangle(834, HEIGHT - 386, 940, HEIGHT - 372);
          readingType := 1;
          reading := true;
      end;
      '2': begin
          FillRectangle(820, HEIGHT - 364, 940, HEIGHT - 350);
          readingType := 2;
          reading := true;
      end;
      '3': begin
          FillRectangle(880, HEIGHT - 342, 940, HEIGHT - 328);
          readingType := 3;
          reading := true;
      end;
    end;
  end;
end;

Label reset;

begin
  OnKeyDown := KeyDown;
  OnKeyPress := KeyPressed;
  
  reset:
  pause := false;
  started := false;
  resetGame := false;
  ShowInfo();
  NewGame();
  
  while true do begin
    if (started) and not (pause) then Play();
    if resetGame then goto reset;
    if reading then ReadingFromKeybord();
  end;
  
end.