CREATE OR REPLACE FUNCTION 
single_number_value (
   table_in    IN VARCHAR2,
   column_in   IN VARCHAR2,
   where_in    IN VARCHAR2)
   RETURN NUMBER
IS
   l_return   NUMBER;
BEGIN
   EXECUTE IMMEDIATE
         'SELECT '
      || column_in
      || ' FROM '
      || table_in
      || ' WHERE '
      || where_in
      INTO l_return;
   RETURN l_return;
END;

select single_number_value('artist','artistid','name=''AC/DC''') from dual;

select * from dual;

SELECT *
FROM ARTIST
WHERE upper(NAME) LIKE 'AERO%';

select artistid
from artist
where name='AC/DC';

CREATE OR REPLACE FUNCTION row_for_employee_id (
   employee_id_in IN employee.employeeid%TYPE)
   RETURN employee%ROWTYPE
IS
   l_employee   employee%ROWTYPE;
BEGIN
   SELECT *
     INTO l_employee
     FROM employee e
    WHERE e.employeeid = 
       row_for_employee_id.employee_id_in;

   RETURN l_employee;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      RETURN NULL;
END;

DECLARE
   l_employee   employee%ROWTYPE;
BEGIN
   l_employee := 
      row_for_employee_id (4);

   DBMS_OUTPUT.put_line (
      l_employee.lastname);
END;

CREATE OR REPLACE PROCEDURE 
show_number_values (
   table_in    IN VARCHAR2,
   column_in   IN VARCHAR2,
   where_in    IN VARCHAR2)
IS
   TYPE values_t IS TABLE OF NUMBER;

   l_values   values_t;
BEGIN
   EXECUTE IMMEDIATE
         'SELECT '
      || column_in
      || ' FROM '
      || table_in
      || ' WHERE '
      || where_in
      BULK COLLECT INTO l_values;

   FOR indx IN 1 .. l_values.COUNT
   LOOP
      DBMS_OUTPUT.put_line 
      (l_values (indx));
   END LOOP;
END;

execute show_number_values('employee','employeeid','title=''IT Staff''');

DECLARE
   stock_price NUMBER := 9.73;
--   net_earnings NUMBER := 10;
   net_earnings VARCHAR2(50) := 'ERRO';
   pe_ratio NUMBER;
BEGIN
-- Calculation might cause division-by-zero error.
   pe_ratio := stock_price / net_earnings;
   DBMS_OUTPUT.PUT_LINE('Price/earnings ratio = ' || pe_ratio);
EXCEPTION  -- exception handlers begin
-- Only one of the WHEN blocks is executed.
   WHEN ZERO_DIVIDE THEN  -- handles 'division by zero' error
      DBMS_OUTPUT.PUT_LINE('Company must have had zero earnings.');
      pe_ratio := NULL;
   WHEN OTHERS THEN  -- handles all other errors
--      DBMS_OUTPUT.PUT_LINE('Some other kind of error occurred.');
      pe_ratio := NULL;
      raise_application_error(-20112,'Some other kind of error occurred.');
END; 

