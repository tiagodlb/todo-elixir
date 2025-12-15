# Elixir Todo List

## Informações

| Item | Detalhe |
| :--- | :--- |
| **Nome do Aluno** | Tiago de Lima Batista |
| **Link do Tutorial Original** | https://profsergiocosta.notion.site/Como-Criar-um-App-Todo-List-com-Elixir-e-LiveView-do-Zero-2a8cce97509380eba53fc82bbeb08435 |

---

## Descrição

Este projeto implementa uma aplicação de lista de tarefas (CRUD - Create, Read, Update, Delete) desenvolvida na stack **Elixir/Phoenix**.

O módulo principal utiliza **Phoenix LiveView** para gerenciar o estado da aplicação e renderizar a interface do usuário em tempo real. Isso proporciona uma experiência reativa e eficiente através de uma única conexão WebSocket.

A persistência de dados é gerenciada pelo **Ecto** (com PostgreSQL), e a estilização front-end é facilitada pela integração com **DaisyUI** e Tailwind CSS.

---

##  Requisitos

Para configurar e executar esta aplicação, são necessários os seguintes componentes instalados em seu ambiente:

* **Elixir** (Versão 1.14+)
* **Erlang/OTP** (Versão 25+)
* **PostgreSQL** (Servidor de Banco de Dados)
* **Node.js** (Versão 18+)
* **npm** ou **Yarn**

---

## Como Rodar a Aplicação

Siga os passos abaixo para baixar o projeto, configurar o banco de dados e iniciar o servidor.

### 1. Clonagem e Acesso ao Repositório

Obtenha o código-fonte do projeto e navegue para o diretório principal:

```bash
git clone https://github.com/tiagodlb/todo-elixir.git
cd elixir_todo_list
````

### 2\. Instalação de Dependências

Baixe e instale as dependências do Elixir e do JavaScript:

```bash
# 1. Dependências do Elixir
mix deps.get

# 2. Dependências do Frontend (Tailwind CSS, DaisyUI, etc.)
npm install --prefix assets
```

### 3\. Configuração do Banco de Dados (Ecto/PostgreSQL)

O projeto utiliza o Ecto com PostgreSQL. Certifique-se de que o servidor PostgreSQL esteja ativo.

```bash
# 1. Cria o banco de dados conforme configurado em config/dev.exs
mix ecto.create

# 2. Executa as migrações para configurar a(s) tabela(s) (ex: 'tasks')
mix ecto.migrate
```

> **Nota:** Se o `mix ecto.create` falhar, verifique e ajuste as credenciais de usuário e senha do PostgreSQL em `config/dev.exs` para que correspondam à sua configuração local.

### 4\. Iniciar o Servidor Phoenix

Com as dependências instaladas e o banco de dados configurado, inicie o servidor Phoenix:

```bash
mix phx.server
```

### 5\. Acesso

A aplicação estará acessível através de um navegador web no endereço: **`http://localhost:4000/`**

-----

## Estrutura de Código

Os componentes chave para a funcionalidade da lista de tarefas residem nos seguintes módulos e diretórios:

| Caminho | Módulo/Função | Descrição Técnica |
| :--- | :--- | :--- |
| `lib/elixir_todo_list_web/live/todo_live.ex` | `ElixirTodoListWeb.TodoLive` | Implementa a arquitetura LiveView. Contém `mount/3`, `handle_event/3` e a função `render/1` (H.eex/HEEx) que define o HTML e a lógica reativa da UI. |
| `lib/elixir_todo_list/task.ex` | `ElixirTodoList.Task` | O Schema Ecto que mapeia a estrutura da tabela `tasks` no PostgreSQL. Contém as regras de validação (`changeset/2`). |
| `lib/elixir_todo_list/repo.ex` | `ElixirTodoList.Repo` | Módulo de abstração do banco de dados para operações CRUD (consulta, inserção, atualização). |

```