# PostgreSQL Server on Kubernetes with StorageOS persistent Storage

This example shows an example of how to deploy PostgreSQL Server on Kubernetes with
PostgreSQL data being written to a StorageOS persistent volume. The files create a
stateful set that can be used *AFTER* a StorageOS cluster has been created. For
more information on how to install a StorageOS cluster please see
[the StorageOS documentation](https://docs.ondat.io/docs/install/)
for more information.

## Deploy

In order to deploy PostgreSQL you just need to clone this repository and use
kubectl to create the Kubernetes objects. 

```bash
git clone git@github.com:ondat/use-cases.git ondat-usecases
cd ondat-usecases/application-examples/
kubectl create -f ./postgresql
```
Once this is done you can check that a postgres pod is running

```bash
kubectl get pods -w -l app=postgres
   NAME        READY    STATUS    RESTARTS    AGE
   postgres-0     1/1      Running    0          1m
```

Connect to the PostgreSQL client pod and connect to the PostgreSQL server through the
service
```bash
$ kubectl exec -it postgres-0 -- psql -h postgres-0.postgres -U testuser userdb
postgres -c "\l"
Password for user primaryuser: password
                       List of Databases
 Name    |  Owner   | Encoding  | Collate | Ctype |   Access privileges
-----------+----------+-----------+---------+-------+-----------------------
postgres  | postgres | SQL_ASCII  | C       | C     |
template0 | postgres | SQL_ASCII | C       | C     | =c/postgres          +
         |          |           |         |       | postgres=CTc/postgres
template1 | postgres | SQL_ASCII | C       | C     | =c/postgres          +
         |          |           |         |       | postgres=CTc/postgres
userdb    | postgres | SQL_ASCII | C       | C     | =Tc/postgres         +
         |          |           |         |       | postgres=CTc/postgres+
         |          |           |         |       | testuser=CTc/postgres
(4 rows)
```

The password for the primary user is password. You can see this is set in
the ConfigMap file.

