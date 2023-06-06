unit Graphic;

interface
type 
  str = string[30];
    StrArray = record
    isDigit: boolean;
    value: array of str;
  end;
procedure displaySplashScreen;
procedure displayWelcomeMessage(name: string);
procedure displayAuth;
procedure displayTableName(name: string);
procedure displayMenu(actions: array of string);
function selectOperation( actions: array of string ): integer;
procedure printTable(data: array of StrArray);
procedure printPartTable(data: array of StrArray; row, column, len : integer);


implementation

uses crt;

const
  sec = 2000;
 var
  current      : integer;
  currentIndex : integer;
  indexEnd     : integer;
{ Процедура для вывода заставки                     }
procedure displaySplashScreen;
begin
  SetWindowSize(150, 30);
  TextBackground(blue);
  writeln('┌──────────────────────────────┐');
  writeln('│                              │');
  writeln('│    Информационная система    │');
  writeln('│                              │');
  writeln('│  Выполнил: студент гр. 1413  │');
  writeln('│       Конов Александр        │');
  writeln('│                              │');
  writeln('└──────────────────────────────┘');
  delay(sec);
  ClrScr;
end;

{ Процедура для вывода приветственного сообщения    }
procedure displayWelcomeMessage(name: string);
begin
  writeln('┌', '─' * 52, '┐');
  writeln('│', ' ':52, '│');
  writeln('│   Добро пожаловать, ', name, ' ' * (30 - Length(name)), ' │');
  writeln('│   Загрузка базы данных...', ' ':26, '│');
  writeln('│', ' ':52, '│');
  writeln('└', '─' * 52, '┘');
  delay(sec);
  ClrScr;
end;

procedure displayAuth;
begin
  writeln('┌──────────────────────────────┐');
  writeln('│                              │');
  writeln('│         Авторизация          │');
  writeln('│                              │');
  writeln('└──────────────────────────────┘');
end;

procedure displayTableName(name: string);
begin
  writeln('┌──────────────────────────────────────────┐');
  writeln('│                                          │');
  Writeln('|  Таблица: ', name, ' ' * (30 - Length(name)), ' │');
  writeln('│                                          │');
  writeln('└──────────────────────────────────────────┘');
end;

procedure displayActions( actions : array of string; num : integer );
begin
  gotoxy(4, currentIndex);
  for var i := 0 to High(actions) do
  begin
   gotoxy(4, currentIndex + i);
   
   if i = num then
      TextBackground(red)
   else
     TextBackground(blue);
   
   write(actions[i]);
   
   TextBackground(blue);
   write(' ' * (28 - Length(actions[i])), '│');
  end;
  gotoxy(4, currentIndex + num);
end;

procedure displayMenu(actions: array of string);
begin
  writeln('┌──────────────────────────────┐');
  writeln('│                              │');
  writeln('│         Операции             │');
  writeln('│                              │');
  
  currentIndex := WhereY();
  
  for var i := 0 to High(actions) do
    writeln('│  ', actions[i], ' ' * (28 - Length(actions[i])), '│');
  
  writeln('│                              │');
  writeln('└──────────────────────────────┘');
  
  indexEnd := WhereY();
  gotoxy(4, indexEnd);

end;

{ Функция для подтверждения выбранной операции                     }
{ Параметры: min     - минимальное число                           }
{            max     - максимально число                           }  
function selectOperation( actions: array of string ): integer;
var
  temp: integer;
  line: string;
  code: integer;
begin
  
  
  var ch : char;
  var current := 0;
  
  displayActions(actions, current);
  
  repeat
    ch := readkey;
    if ch = #0 then
      ch := readkey;
    case ch of
      #27: break;
      #40: // Стерлка вниз
        begin  
          if (current + 1) = Length(actions) then
            current := High(actions)
          else
            current := current + 1;
          displayActions(actions, current);
        end;
      #38: // Стрeлка вверх
        begin
            if (current - 1) < 0 then
              current := 0
            else
              current := current - 1;

          displayActions(actions, current);
        end;
      #13: // Enter
        begin
          break;
        end
    end;
  until false; 
  Result := current;
  gotoxy(4, indexEnd);
end;

{ Процедура для вывода содержимого массива в виде таблицы              }
{ Параметры: data        - данные для вывода в терминал                }
procedure printTable(data: array of StrArray);
var
  countColumn, countRow: integer;
begin
  writeln();
  write(' ':8, '|');
  
  countColumn := Length(data);
  countRow    := Length(data[0].value);
  
  for var i := 0 to countColumn - 1 do
    write(('   Столбец ' + inttostr(i)):30, '|');
  writeln();
  
  write('+', '-' * 7, '+');
  for var i := 0 to countColumn - 1 do
    write('-' * 30, '+');
  writeln();
  
  for var i := 0 to countRow - 1 do
  begin
    for var j := 0 to countColumn - 1 do
    begin
      if j = 0 then
        write('| ', i:5, ' |');
      write(data[j].value[i]:30, '|'); 
    end;
    writeln();
  end;
  writeln();
  indexEnd := WhereY();
end;

{ Процедура для вывода части содержимого массива в виде таблицы        }
{ Параметры: data        - данные для вывода в терминал                }
{            row         - начальная строка                            }
{            column      - начальный столбец                           }
{            len         - длина                                       }
procedure printPartTable(data: array of StrArray; row, column, len : integer);
var
  countColumn, countRow: integer;
begin
  writeln();
  write(' ':8, '|');
  
  countColumn := Length(data);
  countRow    := Length(data[0].value);
  
  if (row + len) < countRow then
    countRow := row + len;
  
  if (column + len) < countColumn then
    countColumn := column + len;
  
  for var i := column to countColumn - 1 do
    write(('   Столбец ' + inttostr(i)):30, '|');
  writeln();
  
  write('+', '-' * 7, '+');
  for var i := column to countColumn - 1 do
    write('-' * 30, '+');
  writeln();
  
  for var i := row to countRow - 1 do
  begin
    for var j := column to countColumn - 1 do
    begin
      if j = column then
        write('| ', i:5, ' |');
      write(data[j].value[i]:30, '|'); 
    end;
    writeln();
  end;
  writeln();
  indexEnd := WhereY();
end;

end.