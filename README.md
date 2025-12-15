# Elixir Todo List - Aplicação CRUD com Phoenix LiveView

Este projeto implementa uma aplicação de lista de tarefas (CRUD - Create, Read, Update, Delete) desenvolvida na stack **Elixir/Phoenix**. O módulo principal utiliza **Phoenix LiveView** para gerenciar o estado da aplicação e renderizar a interface do usuário em tempo real, mantendo uma experiência de usuário eficiente e reativa através de uma única conexão WebSocket.

## Requisitos do Sistema

Para configurar e executar esta aplicação, são necessários os seguintes componentes:

  * **Elixir** (Versão 1.14+)
  * **Erlang/OTP** (Versão 25+)
  * **PostgreSQL** (Servidor de Banco de Dados)
  * **Node.js** (Versão 18+)
  * **npm** ou **Yarn**

## 1\. Instalação e Configuração

Siga os passos abaixo para preparar o ambiente de desenvolvimento e o banco de dados.

### 1.1. Clonagem do Repositório

Obtenha o código-fonte do projeto:

```bash
git clone [URL_DO_SEU_REPOSITÓRIO]
cd elixir_todo_list
```

### 1.2. Instalação de Dependências

Baixe e instale as dependências do Elixir e do JavaScript:

```bash
# Dependências do Elixir
mix deps.get

# Dependências do Frontend (Tailwind CSS, etc.)
npm install --prefix assets
```

### 1.3. Configuração do Banco de Dados

O projeto utiliza o Ecto com PostgreSQL. É necessário criar o banco de dados e aplicar as migrações:

```bash
# 1. Cria o banco de dados configurado em config/dev.exs
mix ecto.create

# 2. Executa as migrações para configurar a tabela 'tasks'
mix ecto.migrate
```

**Nota:** Se o `mix ecto.create` falhar, verifique se suas credenciais de usuário e senha do PostgreSQL estão corretas em `config/dev.exs`.

## 2\. Execução da Aplicação

Inicie o servidor Phoenix a partir do diretório raiz do projeto:

```bash
mix phx.server
```

### 2.1. Acesso

O servidor será iniciado na porta padrão.

A aplicação estará acessível através de um navegador web no endereço:

**`http://localhost:4000/`**

## 3\. Estrutura de Código

Os componentes chave para a funcionalidade da lista de tarefas residem nos seguintes módulos e diretórios:

| Caminho | Módulo/Função | Descrição Técnica |
| :--- | :--- | :--- |
| `lib/elixir_todo_list_web/live/todo_live.ex` | `ElixirTodoListWeb.TodoLive` | Implementa a arquitetura LiveView. Contém `mount/3`, `handle_event/3` e a função `render/1` (H.eex/HEEx) que define o HTML e a lógica reativa da UI. |
| `lib/elixir_todo_list/task.ex` | `ElixirTodoList.Task` | O Schema Ecto que mapeia a estrutura da tabela `tasks` no PostgreSQL. Contém as regras de validação (`changeset/2`). |
| `lib/elixir_todo_list/repo.ex` | `ElixirTodoList.Repo` | Módulo de abstração do banco de dados para operações CRUD (consulta, inserção, atualização). |