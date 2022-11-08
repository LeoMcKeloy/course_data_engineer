create type grades as enum ('A', 'B', 'C', 'D', 'E');
create type levels as enum ('jun', 'middle', 'senior', 'lead');

create table public.departments
(
    department_id bigserial
        constraint departments_pk
            primary key,
    head_name varchar(255) not null,
    count integer,
    name varchar(255) not null
);

create table public.employees
(
    employee_id bigserial
        constraint employees_pk
            primary key,
    full_name varchar(255) not null,
    birthday date,
    start_date date,
    job_title varchar(255),
    level levels,
    salary integer,
    department_id bigint references departments(department_id),
    access boolean
);

create table public.employees_grades
(
    employees_grades_id bigserial
        constraint employees_grades_pk
            primary key,
    employee_id bigint references employees(employee_id),
    first_quarter grades not null,
    second_quarter grades not null,
    third_quarter grades not null,
    fourth_quarter grades not null
);

insert into departments (head_name, count, name) values
                                                     ('Иванов Иван Иванович', 10, 'IT'),
                                                     ('Сидоров Иван Петрович', 8, 'Бухгалтерия'),
                                                     ('Петрова Мария Геннадьевна', 12, 'HR');


insert into employees
(full_name, birthday, start_date, job_title, level, salary, department_id, access) values
                                                                                       ('Петров Петр Сергеевич', '1985-02-10', '2020-03-15', 'разработчик', 'middle', 180000, 1, true),
                                                                                       ('Попова Марина Евгеньевна', '1987-03-11', '2021-04-14', 'разработчик', 'jun', 80000, 1, true),
                                                                                       ('Суркова Софья Валерьевна', '1982-06-05', '2019-04-14', 'тестировщик', 'middle', 170000, 1, false),
                                                                                       ('Жуков Павел Иванович', '1993-06-24', '2018-06-15', 'разработчик', 'senior', 290000, 1, true),
                                                                                       ('Абрамов Анатолий Ильич', '1995-09-16', '2019-08-17', 'бухгалтер', 'senior', 150000, 2, true),
                                                                                       ('Васильева Мария Геннадьевна', '1986-01-18', '2017-11-18', 'hr', 'middle', 120000, 3, false),
                                                                                       ('Иванов Александр Иванович', '1979-04-11', '2015-11-18', 'бухгалтер', 'lead', 170000, 2, true),
                                                                                       ('Сидоров Дмитрий Петрович', '1998-10-22', '2018-04-19', 'бухгалтер', 'jun', 65000, 2, false),
                                                                                       ('Петрова Светлана Дмитриевна', '1997-03-01', '2019-05-10', 'hr', 'middle', 150000, 3, true);

insert into departments (head_name, count, name) values
    ('Соколов Александр Иванович', 3, 'Интеллектуальный анализ данных');

insert into employees
(full_name, birthday, start_date, job_title, level, salary, department_id, access) values
                                                                                       ('Попов Игорь Александрович', '1989-02-12', '2022-10-15', 'инженер данных', 'middle', 220000, 4, true),
                                                                                       ('Игнатова Елена Васильевна', '1987-03-19', '2022-10-14', 'инженер данных', 'senior', 290000, 4, true);

insert into employees_grades
(employee_id, first_quarter, second_quarter, third_quarter, fourth_quarter) values
                                                                                (1, 'A', 'A', 'B', 'A'),
                                                                                (2, 'B', 'A', 'A', 'A'),
                                                                                (3, 'A', 'D', 'A', 'C'),
                                                                                (4, 'A', 'A', 'B', 'A'),
                                                                                (5, 'C', 'A', 'A', 'D'),
                                                                                (6, 'B', 'A', 'C', 'A'),
                                                                                (7, 'E', 'A', 'A', 'B'),
                                                                                (8, 'D', 'B', 'D', 'A'),
                                                                                (9, 'A', 'C', 'A', 'B'),
                                                                                (10, 'A', 'C', 'A', 'A'),
                                                                                (11, 'C', 'A', 'A', 'B');

select employee_id, full_name, DATE_PART('year', '2022-11-07'::date) - DATE_PART('year', start_date::date) from employees;

select employee_id, full_name, DATE_PART('year', '2022-11-07'::date) - DATE_PART('year', start_date::date) from employees limit 3;

select employee_id from employees where access = true;

select employee_id from
    (select employee_id from employees_grades
     where ((first_quarter = 'D' OR first_quarter = 'E') OR (second_quarter = 'D' OR second_quarter = 'E')
         OR (third_quarter = 'D' OR third_quarter = 'E') OR (fourth_quarter = 'D' OR fourth_quarter = 'E'))) as egei;

select max(salary) max_salary from employees;

select name from departments order by count desc limit 1;

select employee_id from employees order by start_date;

select level, avg(salary) salary_by_level from employees group by level;

CREATE FUNCTION to_number(gr grades) RETURNS float AS $f$
DECLARE result float;
BEGIN

case
        when gr = 'D' then result := -0.1;
when gr = 'A' then result := 0.2;
when gr = 'B' then result := 0.1;
when gr = 'E' then result := -0.2;
else result = 0.0;
end case;

RETURN result;
END;
$f$
LANGUAGE plpgsql;

alter table employees add column bonus float default 0.0;

update employees
set bonus = eib.bonus
    from (select employee_id, (1.0 + coalesce(q1, 0) + coalesce(q2, 0) + coalesce(q3, 0) + coalesce(q4, 0)) as bonus
    from (select employee_id, to_number(first_quarter) as q1
               , to_number(second_quarter) as q2, to_number(third_quarter) as q3, to_number(fourth_quarter) as q4
          from employees_grades) qtr) as eib
where eib.employee_id = employees.employee_id;