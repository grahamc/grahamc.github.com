---
layout: post
title: Listing Users with Database Access
---

```sql
SELECT User FROM mysql.db WHERE Db = 'databasename';
```

Only issue with this, is it doesn't list the users who have global permissions
(ie: `*.*`).
