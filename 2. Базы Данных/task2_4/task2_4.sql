-- a
select split_part(full_name, ' ', 1) from employees order by salary desc limit 1;

-- b
select split_part(full_name, ' ', 1) from employees order by full_name;

-- c
select level, avg(DATE_PART('year', current_date) - DATE_PART('year', start_date::date)) from employees group by level;

-- d
select split_part(e.full_name, ' ', 1), d.name from employees e join departments d on e.department_id = d.department_id;

-- e
select sub.name, split_part(sub.full_name, ' ', 1)
from (
         select d.name,
                e.full_name,
                salary,
                max(salary) over (partition by d.name) as max_salary
         from departments d join employees e on d.department_id = e.department_id
     ) sub
where sub.salary = max_salary;

-- f
select sub.name, sub.avg_bonus
from (
         select d.name,
                avg(bonus) as avg_bonus
         from departments d join employees e on d.department_id = e.department_id
         group by d.name
     ) sub
order by sub.avg_bonus desc limit 1;

-- g
create function idx_salary(salary integer, bonus float) RETURNS float AS $func$
DECLARE result integer;
BEGIN

case
        when bonus > 1.2 then result := salary * 1.2;
when bonus >= 1.0 and bonus <= 1.2 then result := salary * 1.1;
else result = salary;
end case;

RETURN result;
END;
$func$
LANGUAGE plpgsql;


alter table employees add column indexing_salary int default 0;
update employees SET indexing_salary = idx_salary(salary, bonus);

-- h
with avgexp as (
    select d.name, avg(DATE_PART('year', current_date) - DATE_PART('year', start_date::date)) as avg_exp
    from employees e join departments d on d.department_id = e.department_id
    group by d.name
)
   , avgslr as (
    select d.name, avg(salary) as avg_salary
    from employees e join departments d on d.department_id = e.department_id
    group by d.name
)
   , juncnt as (
    select d.name, count(e.employee_id) junior
    from    departments d
                join
            employees e
            on d.department_id = e.department_id
    where level = 'jun'
    group by
        d.name
)
   , midcnt as (
    select d.name, count(e.employee_id) middle
    from    departments d
                join
            employees e
            on d.department_id = e.department_id
    where level = 'middle'
    group by
        d.name
)
   , snrcnt as (
    select d.name, count(e.employee_id) senior
    from    departments d
                join
            employees e
            on d.department_id = e.department_id
    where level = 'senior'
    group by
        d.name
)
   , ldcnt as (
    select d.name, count(e.employee_id) lead
    from    departments d
                join
            employees e
            on d.department_id = e.department_id
    where level = 'lead'
    group by
        d.name
)
   , smslr as (
    select d.name, sum(salary) sum_salary
    from    departments d
                join
            employees e
            on d.department_id = e.department_id
    group by
        d.name
)
   , smindslr as (
    select d.name, sum(indexing_salary) sum_index_salary
    from    departments d
                join
            employees e
            on d.department_id = e.department_id
    group by
        d.name
)
   , grdA as (
    select subq2.name, coalesce(q1, 0) + coalesce(q2, 0) + coalesce(q3, 0) + coalesce(q4, 0) A
    from
        (select d.name, count(first_quarter) q1
         from employees_grades eg join employees e on eg.employee_id = e.employee_id
                                  join departments d on e.department_id = d.department_id
         where first_quarter = 'A'
         group by d.name) subq1
            right join
        (select d.name, count(second_quarter) q2
         from employees_grades eg join employees e on eg.employee_id = e.employee_id
                                  join departments d on e.department_id = d.department_id
         where second_quarter = 'A'
         group by d.name) subq2 on subq1.name = subq2.name
            right join
        (select d.name, count(third_quarter) q3
         from employees_grades eg join employees e on eg.employee_id = e.employee_id
                                  join departments d on e.department_id = d.department_id
         where third_quarter = 'A'
         group by d.name) subq3 on subq3.name = subq2.name
            right join
        (select d.name, count(fourth_quarter) q4
         from employees_grades eg join employees e on eg.employee_id = e.employee_id
                                  join departments d on e.department_id = d.department_id
         where fourth_quarter = 'A'
         group by d.name) subq4 on subq4.name = subq3.name
)
   , bnscf as (
    select d.name, avg(bonus) avg_bonus
    from    departments d
                join
            employees e
            on d.department_id = e.department_id
    group by
        d.name
)
   , bnssm as (
    select d.name, sum(bonus_sm) bonus_sum
    from    departments d
                join
            (select department_id, salary * bonus as bonus_sm from employees) b
            on b.department_id = d.department_id
    group by
        d.name
)

select avgexp.name, head_name, count count_employees, avgexp.avg_exp, avgslr.avg_salary,
       coalesce(juncnt.junior, 0) junior, coalesce(midcnt.middle, 0) middle,
       coalesce(snrcnt.senior, 0) senior, coalesce(ldcnt.lead, 0) lead,
       smslr.sum_salary, smindslr.sum_index_salary, grdA.A, bnscf.avg_bonus, bnssm.bonus_sum,
       bonus_sum + sum_salary as bonus_plus_salary, bonus_sum + sum_index_salary as bonus_plus_salary_indx,
       (sum_index_salary - sum_salary) as diff
from departments
         join avgexp on departments.name = avgexp.name
         join avgslr on departments.name = avgslr.name
         left join juncnt on departments.name = juncnt.name
         left join midcnt on departments.name = midcnt.name
         left join snrcnt on departments.name = snrcnt.name
         left join ldcnt on departments.name = ldcnt.name
         join bnscf on departments.name = bnscf.name
         join smslr on departments.name = smslr.name
         join smindslr on departments.name = smindslr.name
         join grdA on departments.name = grdA.name
         join bnssm on departments.name = bnssm.name;