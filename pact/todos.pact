;;
;; todos smart contract
;;

(define-namespace 'todo (read-keyset 'user-ks) (read-keyset 'admin-ks))
(namespace 'todo)
;; admin keyset definition
(define-keyset "todo.todo-admin-keyset"
  (read-keyset "todo-admin-keyset"))

;; todos module, administered by keyset
(module todos "todo.todo-admin-keyset"
  " Smart contract module for TODO-MVC pact app.   \
  \ Tables:                                        \
  \ todo -- holds todo entries"

  ;; todo schema and table
  (defschema todo
    "Row type for todos."
     title:string
     completed:bool
     deleted:bool
     index:integer)

  (deftable todo-table:{todo})

  ;;
  ;; API functions
  ;;

  (defun new-todo (id title)
    "Create new todo with ENTRY and DATE."
    
     (insert todo-table id {
        "title": title,
        "completed": false,
        "deleted": false,
        "index": (length (keys todo-table)) 
    })

    (set-todo-index id 0 (length (keys todo-table))) 
  )

  (defun toggle-todo-status (id:string)
    "Toggle completed status flag for todo at ID."
    (with-read todo-table id {
      "completed":= state
      }
      (update todo-table id {
        "completed": (not state) })))

  (defun edit-todo (id:string title)
    "Update todo ENTRY at ID."
    (update todo-table id {
      "title": title }))

  (defun delete-todo (id:string)
    "Delete todo title at ID (by setting deleted flag)."
    (update todo-table id {
      "deleted": true }))

  (defun read-todo:object (id:string)
    "Read a single todo"
    (+ {'id: id} (read todo-table id)))

  (defun read-todos:[object{todo}] ()
    "Read all todos."
    (sort ['index] (map (read-todo) (keys todo-table))))

  (defun apply-index-correction(todo)
    (with-read todo-table (at 'id todo) {
      "index":= index
    }
    (update todo-table (at 'id todo) {
      "index": (+ index (at "correction" todo))
    })) 
  )

  (defun get-index-correction(new-index old-index index) 
    (if (< new-index old-index) 
        (if (and (< index old-index) (>= index new-index)) 1 0) 
        (if (and (> index old-index) (<= index new-index)) -1 0))
  )

  (defun append-index-correction(new-index old-index todo) 
    (+ { "correction": (get-index-correction new-index old-index (at 'index todo)) } todo)
  )

  (defun set-todo-index(id new-index old-index)
    "Set todo index"

    (map (apply-index-correction) 
    (filter (compose (at 'correction ) (!= 0))
    (map (append-index-correction new-index old-index)
    (map (read-todo) (keys todo-table)))))

    (update todo-table id {
      "index": new-index
    })
  )
)

(create-table todo-table)
;done
