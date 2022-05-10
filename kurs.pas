﻿program informationSystem;

uses crt;

const
  countUsers = 3;
  sec = 2000;
  countAttempts = 5;
  maxLength = 30;

type
  AuthData = record
    login: ShortString;
    pass: ShortString;
    isAdmin: boolean;
  end;
  
  str = string[maxLength];
  
  Users = array[0..countUsers] of AuthData;
  { Тип для записи в файл }
  FileTable = record
    name: str;
    countRow: integer;
    countColumn: integer;
    data: array [0..100, 0..100] of str;
  end;
  StrArray = record
    isDigit: boolean;
    value: array of str;
  end;
  Table = record
    name: str;
    data: array of StrArray;
  end;

var
  currentUser: AuthData;
  isAuth: boolean;
  tables: array of Table;

function actionConfirmed(message: string): boolean;
var
  value: string;
begin
  Write(message);
  Read(value);
  Result := value = 'Да';
end;

function indexConfirmed(message: string; mas: System.Array) : integer;
var
  temp: integer;
  line: string;
  code: integer;
begin
   
  repeat
    write('  ', message);
    Readln(line);
    VAL(line, temp, code);
    if code <> 0 then writeln('Должно быть число'); 
    
  until (code = 0) and (temp >= 0) and (temp < Length(mas));
  
  Result := temp;
end;

function selectOperation(min: integer; max: integer) : integer;
var
  temp: integer;
  line: string;
  code: integer;
begin
  code := 0;
  repeat
    write('  Выберите действие: ');
    Readln(line);
    VAL(line, temp, code);
    if code <> 0 then writeln('Должно быть число'); 
  until (code = 0) and ((temp >= min) and (temp <= max));
  
  Result := temp;
end;

procedure comeBack;
var
  temp  : integer;
  code  : integer;
  answer: string;
begin
  write('  Возврат - 0 ');
  repeat
    Readln(answer);
    VAL(answer, temp, code);
  until (code = 0) and (temp = 0);
  writeln();
end;

procedure printTable(data: array of StrArray);
var
  countColumn, countRow: integer;
begin
  writeln();
  write(' ':8, '|');
  
  countColumn := Length(data);
  countRow := Length(data[0].value);
  
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
end;

function convertToTable(fileTable: FileTable): Table;
var
  table: Table;
begin
  table.name := fileTable.name;
  table.data := new StrArray[fileTable.countColumn];
  
  for var i := 0 to fileTable.countColumn - 1 do
    table.data[i].value := new str[fileTable.countRow];
  
  for var i := 0 to fileTable.countColumn - 1 do
    for var j := 0 to fileTable.countRow - 1 do
      table.data[i].value[j] := fileTable.data[i][j];
  Result := table;
end;

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

function readAuthData(): Users;

var
  user: AuthData;
  users: Users;
  f: file of AuthData;

begin
  Assign(f, 'auth.data');
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

function deleteColumn(current: array of StrArray; Index: Integer): array of StrArray;
var
  size: Integer;
  Ind: Integer;
begin
  size := Length(current) - 1;
  Writeln(size);
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

function deleteRow(current: StrArray; Index: Integer): StrArray;
var
  size: Integer;
  I, Ind: Integer;
begin
  size := Length(current.value) - 1;
  Writeln(size);
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

function isAuthSuccess(login, pass: string): boolean;
var
  users: Users;
  user: AuthData;
  i: integer;
begin
  users := readAuthData();
  Result := false;
  for i := 0 to countUsers do
  begin
    user := users[i];
    if ((user.login = login) and (user.pass = pass)) then
    begin
      Result := true;
      currentUser := user;
      break;
    end;
    
  end;
end;

procedure displaySplashScreen;
begin
  writeln('┌──────────────────────────────┐');
  writeln('│                              │');
  writeln('│    Информационная система    │');
  writeln('│                              │');
  writeln('└──────────────────────────────┘');
  delay(sec);
  ClrScr;
end;

procedure displayWelcomeMessage;
begin
  writeln('   Добро пожаловать, ', currentUser.login);
  writeln();
  writeln('   Загрузка базы данных...');
  delay(sec);
  ClrScr;
end;

procedure displayAuthScreen;
var
  login, pas: string;
begin
  writeln('┌──────────────────────────────┐');
  writeln('│                              │');
  writeln('│         Авторизация          │');
  writeln('│                              │');
  writeln('└──────────────────────────────┘');
  write('  Логин:  ');
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

procedure displayTables;
var
  i: integer;
begin
  writeln('┌──────────────────────────────┐');
  writeln('│                              │');
  writeln('│           Таблицы            │');
  writeln('│                              │');
  
  if (Length(tables) = 0) then
    writeln('│  Не создано ни одной таблицы │')
  else
  begin
    var table: Table;
    for i := 0 to Length(tables) - 1 do
    begin
      table := tables[i];
      writeln('| ', i, ' - ', table.name);
    end;
  end;
  writeln('│                              │');
  writeln('└──────────────────────────────┘');
end;

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

procedure viewTable();
var
  current : Table;
  oper    : integer;
  num     : integer;
begin
  num := indexConfirmed('Выберите № таблицы: ', tables);
  
  ClrScr;
  current := tables[num];
  
  writeln('┌──────────────────────────────┐');
  writeln('│                              │');
  writeln('│  Таблица "', current.name, '"');
  writeln('│                              │');
  writeln('└──────────────────────────────┘');
  
  var countRow := Length(current.data);
  
  if (countRow <> 0) then
    printTable(current.data);
  
  comeBack();
  ClrScr;
end;

function addColumn(current: Table): Table;
var
  last: integer;
  isDigit: boolean;

begin
  if current.data = nil
    then
    current.data := new StrArray[0];
  
  last := Length(current.data);
  
  SetLength(current.data, last + 1);
  
  if last <> 0 then
  begin
    var len := Length(current.data[0].value);
    current.data[last].value := new str[len];
    isDigit := actionConfirmed('Тип столбца числовой? (Да/Нет)');
    current.data[last].isDigit := isDigit;
  end;
  Result := current;
end;

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

function addRow(current: Table): Table;
var
  last: integer;
begin
  if current.data = nil then
  begin
    Result := current;
    exit;
  end;
  last := Length(current.data[0].value);
  for var i := 0 to Length(current.data) - 1 do
    SetLength(current.data[i].value, last + 1);
  
  Result := current;
end;

function delRow(current: Table): Table;
var
  num: integer;
  answer: string[3];
begin
  if current.data = nil then
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

function sortDescending(arr: array of StrArray; k: integer): array of StrArray;
var
  temp: str;
begin
  var a := copy(arr);
  for var i := 0 to Length(arr) - 1 do
    a[i].value := copy(arr[i].value);
  
  
  for var i := 0 to Length(arr[0].value) - 1 do 
    for var j := 0 to Length(arr[0].value) - i - 1 do 
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

function sortAscending(arr: array of StrArray; k: integer): array of StrArray;
var
  temp: str;
begin
  var a := copy(arr);
  for var i := 0 to Length(arr) - 1 do
    a[i].value := copy(arr[i].value);
  
  
  for var i := 0 to Length(arr[0].value) - 1 do 
    for var j := 0 to Length(arr[0].value) - i - 1 do 
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

procedure sortTable(current: Table);
var
  column   : integer;
  sortData : array of StrArray;
  isDesc   : boolean;
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

procedure editTable();
var
  current : Table;
  num     : integer;
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
    
    writeln('┌──────────────────────────────┐');
    writeln('│                              │');
    writeln('│         Операции             │');
    writeln('│                              │');
    writeln('│  0 - Возврат в меню          │');
    writeln('│  1 - Добавить столбец        │');
    writeln('│  2 - Удалить столбец         │');
    writeln('│  3 - Добавить строку         │');
    writeln('│  4 - Удалить строку          │');
    writeln('│  5 - Изменить ячейку         │');
    writeln('│  6 - Поиск значения          │');
    writeln('│  7 - Сортировка по столбцу   │');
    writeln('│                              │');
    writeln('└──────────────────────────────┘');
    
    var countColumn := Length(current.data);
    
    if (countColumn <> 0) then
      printTable(current.data);
    
    var oper: integer;
    
    oper := selectOperation(0, 7);
    
    case oper of
      0: begin ClrScr; exit; end;
      1: current := addColumn(current);
      2: current := delColumn(current);
      3: current := addRow(current);
      4: current := delRow(current);
      5: current := insertValue(current);
      6: findValue(current);
      7: sortTable(current);
    end;
    
    tables[num] := current;
    ClrScr;
  end;
end;

procedure displayAdminMenu;
var
  oper: integer;
begin
  writeln('┌──────────────────────────────┐');
  writeln('│                              │');
  writeln('│    Операции с таблицами      │');
  writeln('│                              │');
  writeln('│  1 - Просмотреть             │');
  writeln('│  2 - Создать                 │');
  writeln('│  3 - Редактировать           │');
  writeln('│  4 - Удалить                 │');
  writeln('│                              │');
  writeln('└──────────────────────────────┘');
  
  oper := selectOperation(1, 4);
  
  case oper of
    1: viewTable();
    2: 
      begin
        createTable();
        writeTables();
      end;
    3: 
      begin
        editTable();
        writeTables();
      end;
    4: 
      begin
        deleteTable();
        writeTables();
      end;
  end;
end;

procedure displayUserMenu;
var
  oper: integer;
begin
  writeln('┌──────────────────────────────┐');
  writeln('│                              │');
  writeln('│    Операции с таблицами      │');
  writeln('│                              │');
  writeln('│  1 - Просмотреть             │');
  writeln('│  2 - Редактировать           │');
  writeln('│                              │');
  writeln('└──────────────────────────────┘');
  
  oper := selectOperation(1, 2);
  
  case oper of
    1: viewTable();
    2: 
      begin
        editTable();
        writeTables();
      end;
  end;
end;

begin
  displaySplashScreen();
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
  
  displayWelcomeMessage();
  
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