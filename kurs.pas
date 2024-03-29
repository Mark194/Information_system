﻿{ Программа: Информационная система                 }
{ Переменные:                                       }
{ currentUser - текущий авторизованный пользователь }
{ isAuth      - авторизован ли пользователь         }
{ tables      - массив таблиц                       }
{ userList    - массив пользователей                }
program informationSystem;

uses crt, Graphic;

const
  countUsers    = 3;
  sec           = 2000;
  countAttempts = 5;
  maxLength     = 30;

type
  
  AuthData = record
    login   : str;
    pass    : str;
    isAdmin : boolean;
  end;
  
  Users = array[0..countUsers] of AuthData;
  { Тип для записи в файл }
  FileTable = record
    name: str;
    countRow: integer;
    countColumn: integer;
    data: array [0..100, 0..100] of str;
  end;
  Table = record
    name: str;
    data: array of StrArray;
  end;

var
  currentUser : AuthData;
  isAuth      : boolean;
  tables      : array of Table;
  userList    : Users;

{ Функция для подтверждения выбора пользователя         }
{ Параметры: message - выводимое пользователю сообщение }
{            value   - введённое пользователем значение }
function actionConfirmed(message: string): boolean;
var
  value: string;
begin
  Write(message);
  Readln(value);
  Result := value = 'Да';
end;

{ Функция для подтверждения выбора индекса из массива              }
{ Параметры: message - выводимое пользователю сообщение            }
{            mas     - массив, для которого проверяется индекс     }  
function indexConfirmed(message: string; mas: System.Array): integer;
var
  temp: integer;
  line: string;
  code: integer;
begin
  code := 0;
  repeat
    write('  ', message);
    Readln(line);
    VAL(line, temp, code);
    if code <> 0 then writeln('Должно быть число'); 
    
  until (code = 0) and (temp >= 0) and (temp < Length(mas));
  
  Result := temp;
end;

{ Процедура для подтверждения ввода кода возврата                  }
procedure comeBack;
var
  temp: integer;
  code: integer;
  answer: string;
begin
  write('  Возврат - 0 ');
  repeat
    Readln(answer);
    VAL(answer, temp, code);
  until (code = 0) and (temp = 0);
  writeln();
end;

{ Функция для преобразования FileTable в Table                         }
{ Параметры: fileTable - переменная для преобразования                 }
function convertToTable(fileTable: FileTable): Table;
var
  table: Table;
begin
  table.name := fileTable.name;
  table.data := new StrArray[fileTable.countColumn];
  
  for var i := 0 to fileTable.countColumn - 1 do
  begin
    table.data[i].value := new str[fileTable.countRow];
    for var j := 0 to fileTable.countRow - 1 do
      table.data[i].value[j] := fileTable.data[i][j];
  end;
  Result := table;
end;

{ Функция для преобразования Table в FileTable                         }
{ Параметры: table - переменная для преобразования                     }
function convertToFileTable(table: Table): FileTable;
var
  fileTable: FileTable;
begin
  fileTable.name := table.name;
  
  fileTable.countColumn := Length(table.data);
  
  if (table.data = nil) or (fileTable.countColumn = 0) then
  begin
    Result := fileTable;
    exit;
  end;
  
  fileTable.countRow := Length(table.data[0].value);
  
  for var i := 0 to fileTable.countRow - 1 do
    for var j := 0 to fileTable.countColumn - 1 do
      fileTable.data[j][i] := table.data[j].value[i];
  Result := fileTable;
end;


{ Функция для чтения пользователей из файла                             }
function readAuthData(): Users;

var
  user: AuthData;
  users: Users;
  f: file of AuthData;

begin
  Assign(f, 'auth.data');
  if not fileexists('auth.data') then
  begin
    Writeln('Файл auth.data не найден.');
    halt;
  end;
  Reset(f);
  var i := 0;
  while not Eof(f) do
  begin
    Read(f, user);
    users[i] := user;
    i := i + 1;
  end;
  Close(f);
  Result := users;
end;

{ Функция для удаления таблицы из массива таблиц по индексу          }
{ Параметры: V       - массив таблиц                                 }
{            Index   - индекс таблицы для удаления                   }
function deleteElement(V: array of Table; Index: Integer): array of Table;
var
  NewSize: Integer;
  Ind: Integer;
begin
  NewSize := Length(V) - 1;
  if Index > NewSize {Length(V) - 1} then
    raise Exception.Create('Указанный элемент не существует');
  SetLength(Result, NewSize);
  
  Ind := 0;
  for var I := 0 to High(V) do
  begin
    if I <> Index then
    begin
      Result[Ind] := V[I];
      Inc(Ind);
    end;
  end;
  
end;

{ Функция для удаления столбца из массива столбцов по индексу          }
{ Параметры: current       - массив столбцов                           }
{            Index   - индекс столца для удаления                      }
function deleteColumn(current: array of StrArray; Index: Integer): array of StrArray;
var
  size: Integer;
  Ind: Integer;
begin
  size := Length(current) - 1;
  if Index > size then
  begin
    Writeln('Указанный элемент не существует');
    Result := current;
    exit
  end;
  SetLength(Result, size);
  Ind := 0;
  for var I := 0 to High(current) do
  begin
    if I <> Index then
    begin
      Result[Ind] := current[I];
      Inc(Ind);
    end;
  end;
end;

{ Функция для удаления строки из массива строк по индексу              }
{ Параметры: current - массив строк                                    }
{            Index   - индекс строки для удаления                      }
function deleteRow(current: StrArray; Index: Integer): StrArray;
var
  size: Integer;
  I, Ind: Integer;
begin
  size := Length(current.value) - 1;
  if Index > size {Length(V) - 1} then
  begin
    Writeln('Указанный элемент не существует');
    Result := current;
    exit
  end;
  SetLength(Result.value, size);
  Ind := 0;
  for I := 0 to High(current.value) do
  begin
    if I <> Index then
    begin
      Result.value[Ind] := current.value[I];
      Inc(Ind);
    end;
  end;
end;

{ Функция для проверки аутентификации пользователя                     }
{ Параметры: login - логин                                             }
{            pass  - пароль                                            }
function isAuthSuccess(login, pass: string): boolean;
var
  user: AuthData;
  i: integer;
begin
  Result := false;
  for i := 0 to countUsers do
  begin
    user := userList[i];
    if ((user.login = login) and (user.pass = pass)) then
    begin
      Result := true;
      currentUser := user;
      break;
    end;
    
  end;
end;

{ Процедура для вывода авторизации                    }
procedure displayAuthScreen;
var
  login, pas: string;
begin
  displayAuth();
  write('  Логин: ');
  Readln(login);
  write('  Пароль: ');
  Readln(pas);
  isAuth := isAuthSuccess(login, pas);
  if (isAuth) then
  begin
    Writeln('  Авторизация прошла успешно!');
  end
  else
  begin
    Writeln('  Неверный логин или пароль!');
    delay(1000);
  end;
  ClrScr;
end;

{ Процедура для чтения таблиц из файла                }
procedure readTables;
var
  f: file of FileTable;
  table: FileTable;
begin
  Assign(f, 'database.dat');
  if not fileexists('database.dat') then
  begin
    Rewrite(f);
    Close(f);
    exit;
  end;
  Reset(f);
  var i := 0;
  var count := FileSize(f);
  SetLength(tables, count);
  while not Eof(f) do
  begin
    Read(f, table);
    tables[i] := convertToTable(table);
    i := i + 1;
  end;
  Close(f);
end;

{ Процедура для записи таблиц в файл                 }
procedure writeTables;
var
  f: file of FileTable;
  table: FileTable;
  i: integer;
begin
  Assign(f, 'database.dat');
  Rewrite(f);
  
  if (Length(tables) = 0) then
  begin
    Close(f);
    exit;
  end;
  
  for i := 0 to Length(tables) - 1 do
  begin
    table := convertToFileTable(tables[i]);
    Write(f, table);
  end;
  Close(f);
end;

{ Процедура для вывода названий таблиц                 }
procedure displayTables;
var
  i: integer;
begin
  writeln('┌────────────────────────────────────┐');
  writeln('│                                    │');
  writeln('│             Таблицы                │');
  writeln('│                                    │');
  
  if (Length(tables) = 0) then
    writeln('│  Не создано ни одной таблицы │')
  else
  begin
    var table: Table;
    for i := 0 to Length(tables) - 1 do
    begin
      table := tables[i];
      Writeln('| ',i, ' - ', table.name, ' ' * (30 - Length(table.name)), ' │');
    end;
  end;
  writeln('│                                    │');
  writeln('└────────────────────────────────────┘');
end;

{ Процедура для создания таблицы                 }
procedure createTable;
var
  table: Table;
  name: str;
  last: integer;
begin
  Write('Введите имя таблицы: ');  
  Readln(name);
  table.name := name;
  table.data := new StrArray[0];
  last := Length(tables);
  SetLength(tables, Length(tables) + 1);
  tables[last] := table;
  ClrScr;
end;

{ Процедура для удаления таблицы                 }
procedure deleteTable;
var
  num: integer;
  answer: string[3];
begin
  num := indexConfirmed('Выберите № таблицы: ', tables);
  
  if not actionConfirmed('Удалить таблицу? (Да/Нет)') then
  begin
    ClrScr;
    exit;
  end;
  
  tables := deleteElement(tables, num);
  ClrScr;
end;

{ Процедура для отображения имени текущей таблицы и её содержимого }
procedure viewTable();
var
  current: Table;
  oper: integer;
  num: integer;
  startRow: integer;
  startColumn: integer;
  len : integer;
begin
  num := indexConfirmed('Выберите № таблицы: ', tables);
  
  ClrScr;
  current := tables[num];
  
  
  
  var countRow := Length(current.data);
  
  startRow := 0;
  
  startColumn := 0;
  
  len := 3;
  
  while true do
  begin
    
    displayTableName(current.name);
    
    if (countRow <> 0) then
      printPartTable(current.data, startRow, startColumn, len);
    
    var actions: array of string = ('↑', 
                                   '←', 
                                   '→', 
                                   '↓', 
                                   'Возврат');
    
    displayMenu( actions );
    
    oper := selectOperation( actions );
    
    case oper of
      0: startRow := startRow - len;
      1: startColumn := startColumn - len;
      2: startColumn := startColumn + len;
      3: startRow := startRow + len;
      4: begin ClrScr; exit; end;
    end;
    
    if startRow < 0 then startRow := 0;
    
    if startColumn < 0 then startColumn := 0;
    
//    comeBack();
    ClrScr;
    end;
end;

{ Функция для добавления столбца в таблицу                         }
{ Параметры: current - текущая таблица                             }
function addColumn(current: Table): Table;
var
  last: integer;
  isDigit: boolean;

begin
  last := Length(current.data);
  
  SetLength(current.data, last + 1);
  
  var len := Length(current.data[0].value);
  current.data[last].value := new str[len];
  isDigit := actionConfirmed('Тип столбца числовой? (Да/Нет)');
  current.data[last].isDigit := isDigit;
  
  Result := current;
end;

{ Функция для удаления столбца из таблицы                          }
{ Параметры: current - текущая таблица                             }
function delColumn(current: Table): Table;
var
  num: integer;
  answer: string[3];
begin
  
  num := indexConfirmed('Выберите № столбца: ', current.data);
  
  if not actionConfirmed('Удалить столбец? (Да/Нет)') then
  begin
    Result := current;
    exit;
  end;
  
  current.data := deleteColumn(current.data, num);
  Result := current;
end;

{ Функция для создания строки в таблице                            }
{ Параметры: current - текущая таблица                             }
function addRow(current: Table): Table;
var
  last: integer;
begin
  if Length(current.data) = 0 then
  begin
    Result := current;
    exit;
  end;
  
  last := Length(current.data[0].value);
  for var i := 0 to Length(current.data) - 1 do
    SetLength(current.data[i].value, last + 1);
  
  Result := current;
end;

{ Функция для удаления строки из таблицы                           }
{ Параметры: current - текущая таблица                             }
function delRow(current: Table): Table;
var
  num: integer;
begin
  if Length(current.data) = 0 then
  begin
    Result := current;
    exit;
  end;
  
  num := indexConfirmed('Выберите № строки: ', current.data[0].value);
  
  if not actionConfirmed('Удалить строку? (Да/Нет)') then
  begin
    Result := current;
    exit;
  end;
  for var i := 0 to Length(current.data) - 1 do
    current.data[i] := deleteRow(current.data[i], num);
  Result := current;
end;

{ Функция для добавления значения в ячейку таблицы                 }
{ Параметры: current - текущая таблица                             }
function insertValue(current: Table): Table;
var
  row, column: integer;
  value, line: string;
  code: integer;
  temp: real;
begin
  
  column := indexConfirmed('Выберите № столбца: ', current.data);
  
  row := indexConfirmed('Выберите № строки: ', current.data[0].value);
  
  if current.data[column].isDigit then
  begin
    repeat
      write('  Введите значение: ');
      Readln(line);
      VAL(line, temp, code);
      if code <> 0 then writeln('Должно быть число');
    until code = 0;
    value := FloatToStr(temp);
  end
  else
  begin
    write('  Введите значение: ');
    Readln(value);
  end;
  
  current.data[column].value[row] := value;
  Result := current;
end;

{ Процедура для поиска значения в таблице                          }
{ Параметры: current - текущая таблица                             }
procedure findValue(current: Table);
var
  value: string;
  currentData: string;
  count: integer;
begin
  write('  Введите значение: ');
  Readln(value);
  
  for var i := 0 to Length(current.data) - 1 do
    for var j := 0 to Length(current.data[i].value) - 1 do
    begin
      currentData := current.data[i].value[j];
      if currentData = value then
        count := count + 1;
    end;
  
  if count = 0 then
    Writeln('"', value, '" не найдено')
  else
    Writeln('"', value, '" найдено ', count, ' раз');
  
  comeBack();
end;

{ Функция для сортировки по возрастанию                            }
{ Параметры: array - массив для сортировки                         }
{            k     - номер столбца, по которому сортируем          }
function sortDescending(arr: array of StrArray; k: integer): array of StrArray;
var
  temp: str;
begin
  var a := copy(arr);
  for var i := 0 to Length(arr) - 1 do
    a[i].value := copy(arr[i].value);
  
  
  for var i := 0 to Length(arr[0].value) - 1 do 
    for var j := i + 1 to Length(arr[0].value) - 1 do 
    begin
      write(i, j, ' ');
      if (a[k].value[i] > a[k].value[j]) then
      begin
        for var d := 0 to Length(arr) - 1 do
        begin
          temp := a[d].value[i];
          a[d].value[i] := a[d].value[j];
          a[d].value[j] := temp;
        end;
      end;
    end;
  
  Result := a;
end;

{ Функция для сортировки по убыванию                               }
{ Параметры: array - массив для сортировки                         }
{            k     - номер столбца, по которому сортируем          }
function sortAscending(arr: array of StrArray; k: integer): array of StrArray;
var
  temp: str;
begin
  var a := copy(arr);
  for var i := 0 to Length(arr) - 1 do
    a[i].value := copy(arr[i].value);
  
  
  for var i := 0 to Length(arr[0].value) - 1 do 
    for var j := i + 1 to Length(arr[0].value) - 1 do 
    begin
      write(i, j, ' ');
      if (a[k].value[i] < a[k].value[j]) then
      begin
        for var d := 0 to Length(arr) - 1 do
        begin
          temp := a[d].value[i];
          a[d].value[i] := a[d].value[j];
          a[d].value[j] := temp;
        end;
      end;
    end;
  
  Result := a;
end;

{ Процедура для сортировки текущей таблицы                         }
{ Параметры: current - текущая таблица                             }
procedure sortTable(current: Table);
var
  column: integer;
  sortData: array of StrArray;
  isDesc: boolean;
begin
  column := indexConfirmed('Выберите № столбца: ', current.data);
  
  isDesc := actionConfirmed('Сортировать по возрастанию? (Да/Нет)'); 
  
  if isDesc then 
    sortData := sortDescending(current.data, column)
  else
    sortData := sortAscending(current.data, column);
  
  ClrScr;
  writeln('Результат сортировки по столбцу:');
  printTable(sortData);
  
  comeBack();
end;

{ Процедура для изменения таблицы                         }
procedure editTable();
var
  current: Table;
  num: integer;
  startRow : integer;
  startColumn : integer;
  len : integer;
begin
  num := indexConfirmed('Выберите № таблицы: ', tables);
  
  ClrScr;
  current := tables[num];
  
  startRow := 0;
  
  startColumn := 0;
  
  len := 3;

    var actions: array of string = ('Возврат в меню', 
                                 'Добавить столбец', 
                                 'Удалить столбец ', 
                                 'Добавить строку', 
                                 'Удалить строку',
                                 'Изменить ячейку',
                                 'Поиск значения',
                                 'Сортировка по столбцу',
                                 '↑', 
                                 '←', 
                                 '→', 
                                 '↓'
                                 );
  
  while true do
  begin
    
    displayTableName(current.name);
    
    displayMenu( actions );
    
    var countColumn := Length(current.data);
    
    if (countColumn <> 0) then
      printPartTable(current.data, startRow, startColumn, len);
    
    var oper: integer;
    
    
    
    oper := selectOperation(actions);
    
    case oper of
      0: begin ClrScr; exit; end;
      1: current := addColumn(current);
      2: current := delColumn(current);
      3: current := addRow(current);
      4: current := delRow(current);
      5: current := insertValue(current);
      6: findValue(current);
      7: sortTable(current);
      8: startRow := startRow - len;
      9: startColumn := startColumn - len;
      10: startColumn := startColumn + len;
      11: startRow := startRow + len;
    end;
    
    if startRow < 0 then startRow := 0;
    
    if startColumn < 0 then startColumn := 0;
    
    tables[num] := current;
    ClrScr;
  end;
end;

{ Процедура для изменения таблицы                         }
procedure editUserTable();
var
  current: Table;
  num: integer;
begin
  num := indexConfirmed('Выберите № таблицы: ', tables);
  
  ClrScr;
  current := tables[num];
  while true do
  begin
    
    writeln('┌──────────────────────────────┐');
    writeln('│                              │');
    writeln('│  Таблица "', current.name, '"');
    writeln('│                              │');
    writeln('└──────────────────────────────┘');
    
        var actions: array of string = ('Возврат в меню', 
                                 'Изменить ячейку', 
                                 'Поиск значения', 
                                 'Сортировка по столбцу');
    
    displayMenu( actions );
    
    var countColumn := Length(current.data);
    
    if (countColumn <> 0) then
      printTable(current.data);
    
    var oper: integer;
    
    oper := selectOperation(actions);
    
    case oper of
      0: begin ClrScr; exit; end;
      1: current := insertValue(current);
      2: findValue(current);
      3: sortTable(current);
    end;
    
    tables[num] := current;
    ClrScr;
  end;
end;

{ Процедура для вывода меню админа                        }
procedure displayAdminMenu;
var
  oper: integer;
begin
  
          var actions: array of string = ('Просмотреть', 
                                 'Создать', 
                                 'Редактировать', 
                                 'Удалить');
    
    displayMenu( actions );
  
  oper := selectOperation( actions );
  
  case oper of
    0: viewTable();
    1: 
      begin
        createTable();
        writeTables();
      end;
    2: 
      begin
        editTable();
        writeTables();
      end;
    3: 
      begin
        deleteTable();
        writeTables();
      end;
  end;
end;

{ Процедура для вывода меню пользователя                        }
procedure displayUserMenu;
var
  oper: integer;
begin
          var actions: array of string = ( 'Просмотреть',
                                 'Редактировать');
    
  displayMenu( actions );
  
  oper := selectOperation( actions );
  
  case oper of
    0: viewTable();
    1: 
      begin
        editUserTable();
        writeTables();
      end;
  end;
end;

begin
  displaySplashScreen();
  
  userList := readAuthData();
  
  var attempt := 0;
  while (attempt < countAttempts) and not isAuth do
  begin
    displayAuthScreen();
    attempt := attempt + 1;
  end;
  
  if (not isAuth) then
  begin
    writeln('   Прeвышено количество попыток:  ', countAttempts);
    exit;
  end;
  
  displayWelcomeMessage(currentUser.login);
  
  readTables();
  
  while True do
  begin
    displayTables();
    if (currentUser.isAdmin) then
      displayAdminMenu()
    else
      displayUserMenu();
  end;
end.