defmodule ElixirTodoListWeb.TodoLive do
  use ElixirTodoListWeb, :live_view
  alias ElixirTodoList.{Repo, Category}
  alias ElixirTodoList.Task, as: TaskSchema
  import Ecto.Query

  @impl true
  def mount(_params, _session, socket) do
    {:ok, fetch_tasks(assign(socket, filter: "all", category_filter: "all", editing_id: nil, show_new_category_form: false))}
  end

  defp fetch_tasks(socket) do
    tasks = Repo.all(from(t in TaskSchema, order_by: [desc: :inserted_at]))

    categories_from_db = Repo.all(from(c in Category, order_by: :name))

    categories =
      ["all" | Enum.map(categories_from_db, & &1.slug)]
      |> Enum.map(&{&1 |> String.upcase(), &1})

    socket
    |> assign(tasks: tasks, form: to_form(TaskSchema.changeset(%TaskSchema{}, %{})))
    |> assign(categories: categories)
  end

  @impl true
  def handle_event("save_task", %{"task" => params}, socket) do
    category =
      case params do
        %{"new_category" => new_cat} when byte_size(new_cat) > 0 ->
          new_cat |> String.downcase() |> String.trim()
        _ ->
          params["category"] || "geral"
      end

    params = Map.put(params, "category", category)

    case Repo.insert(TaskSchema.changeset(%TaskSchema{}, params)) do
      {:ok, _} ->
        {:noreply, socket |> fetch_tasks() |> put_flash(:info, "Boa! Mais um passo dado!")}

      {:error, cs} ->
        {:noreply, assign(socket, form: to_form(cs))}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    Repo.get!(TaskSchema, id) |> Repo.delete()

    {:noreply,
     socket |> fetch_tasks() |> put_flash(:info, "Tarefa removida. Foco no que importa!")}
  end

  @impl true
  def handle_event("toggle_complete", %{"id" => id}, socket) do
    task = Repo.get!(TaskSchema, id)
    TaskSchema.changeset(task, %{completed: !task.completed}) |> Repo.update()

    msg = if !task.completed, do: "Excelente trabalho!", else: "Tarefa reaberta. Você consegue!"
    {:noreply, socket |> fetch_tasks() |> put_flash(:info, msg)}
  end

  @impl true
  def handle_event("set_filter", %{"filter" => f}, socket),
    do: {:noreply, assign(socket, filter: f)}

  @impl true
  def handle_event("set_category_filter", %{"category_filter" => cf}, socket),
    do: {:noreply, assign(socket, category_filter: cf)}

  @impl true
  def handle_event("toggle_new_category_form", _params, socket),
    do: {:noreply, assign(socket, show_new_category_form: !socket.assigns.show_new_category_form)}

  @impl true
  def handle_event("add_category", %{"category_name" => name}, socket) do
    trimmed_name = String.trim(name)

    if byte_size(trimmed_name) > 0 do
      case Repo.insert(Category.changeset(%Category{}, %{"name" => trimmed_name})) do
        {:ok, _} ->
          {:noreply,
           socket
           |> fetch_tasks()
           |> assign(show_new_category_form: false)
           |> put_flash(:info, "Categoria '#{trimmed_name}' criada com sucesso!")}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Erro ao criar categoria. Tente novamente!")}
      end
    else
      {:noreply, put_flash(socket, :error, "Digite um nome para a categoria!")}
    end
  end

  @impl true
  def handle_event("clear_completed", _params, socket) do
    query = from(t in TaskSchema, where: t.completed == true)
    {count, _} = Repo.delete_all(query)

    msg =
      case count do
        0 -> "Nenhuma tarefa concluída para limpar."
        1 -> "Uma tarefa concluída foi removida!"
        n -> "#{n} tarefas concluídas foram removidas! Excelente foco!"
      end

    {:noreply, socket |> fetch_tasks() |> put_flash(:info, msg)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-[#F4F4F9] text-[#2D3142] p-4 md:p-12 font-sans selection:bg-[#FF5F1F] selection:text-white">
      <div class="max-w-4xl mx-auto">
        <header class="mb-12 relative">
          <div class="flex flex-col gap-2">
            <h1 class="text-6xl md:text-7xl font-black uppercase tracking-tighter leading-none italic">
              Faça<br /><span class="text-[#FF5F1F]">Acontecer.</span>
            </h1>
            <p class="text-lg font-bold border-l-8 border-[#2D3142] pl-4 mt-2">
              <%= if Enum.count(@tasks, &!&1.completed) == 0 do %>
                Tudo limpo! Que tal planejar algo novo?
              <% end %>
              <%= if Enum.count(@tasks, &!&1.completed) == 1 do %>
                Você tem {Enum.count(@tasks, &(!&1.completed))} missão para hoje. Vamos nissa?
              <% else %>
                Você tem {Enum.count(@tasks, &(!&1.completed))} missões para hoje. Vamos nissa?
              <% end %>
            </p>
          </div>
        </header>

        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-10">
          <div class="bg-white border-[3px] border-black p-4 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
            <span class="text-[10px] font-black uppercase text-gray-500 block">Total</span>
            <span class="text-3xl font-black">{length(@tasks)}</span>
          </div>
          <div class="bg-[#CFF27E] border-[3px] border-black p-4 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
            <span class="text-[10px] font-black uppercase block text-black">Em aberto</span>
            <span class="text-3xl font-black text-black">{Enum.count(@tasks, &(!&1.completed))}</span>
          </div>
        </div>

        <section class="mb-12">
          <.form for={@form} phx-submit="save_task" class="group">
            <div class="flex flex-col md:flex-row items-stretch border-[4px] border-black bg-white shadow-[8px_8px_0px_0px_rgba(45,49,66,1)] transition-all focus-within:shadow-[10px_10px_0px_0px_rgba(255,95,31,1)]">
              <div class="flex-grow">
                <.input
                  field={@form[:title]}
                  placeholder="O QUE VAMOS CONQUISTAR AGORA?"
                  class="w-full !border-0 !ring-0 !py-6 !px-6 !text-xl !font-bold !bg-transparent placeholder:text-gray-400 uppercase italic"
                />
              </div>
              <button class="bg-[#2D3142] text-white px-10 py-4 text-xl font-black hover:bg-[#FF5F1F] transition-colors border-t-[4px] md:border-t-0 md:border-l-[4px] border-black uppercase flex items-center justify-center gap-2">
                <span>Criar</span>
                <.icon name="hero-bolt-solid" class="w-5 h-5 text-[#CFF27E]" />
              </button>
            </div>
            <div class="flex gap-4 mt-4">
              <div class="flex items-center gap-2 bg-white border-2 border-black px-3 py-1 shadow-[3px_3px_0px_0px_rgba(0,0,0,1)]">
                <span class="text-[10px] font-black uppercase italic">Prioridade:</span>
                <.input
                  type="select"
                  field={@form[:priority]}
                  options={[{"Baixa", "low"}, {"Média", "medium"}, {"Alta", "high"}]}
                  class="!p-0 !border-0 !bg-transparent !font-black !text-[10px] !ring-0 cursor-pointer uppercase !mt-2 "
                />
              </div>

              <div class="flex items-center gap-2 bg-white border-2 border-black px-3 py-1 shadow-[3px_3px_0px_0px_rgba(0,0,0,1)]">
                <span class="text-[10px] font-black uppercase italic">Categoria:</span>
                <.input
                  type="select"
                  field={@form[:category]}
                  options={Enum.map(@categories, fn {label, value} -> {label, value} end)}
                  class="!p-0 !border-0 !bg-transparent !font-black !text-[10px] !ring-0 cursor-pointer uppercase !mt-2 "
                />
              </div>
            </div>
          </.form>
        </section>

        <div class="flex flex-col gap-4 mb-8">
          <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b-4 border-black pb-4">
            <div class="flex gap-4 items-center">
              <%= for {label, f} <- [{"Tudo", "all"}, {"Ativas", "active"}, {"Concluídas", "completed"}] do %>
                <button
                  phx-click="set_filter"
                  phx-value-filter={f}
                  class={[
                    "text-sm font-black uppercase tracking-widest transition-all",
                    @filter == f && "text-[#FF5F1F] scale-110",
                    @filter != f && "hover:text-[#FF5F1F] opacity-50"
                  ]}
                >
                  {label}
                </button>
              <% end %>
            </div>

            <div class="flex gap-2">
              <button
                phx-click="clear_completed"
                class="bg-red-100 hover:bg-red-500 hover:text-white border-2 border-black px-4 py-1 text-[10px] font-black uppercase transition-all shadow-[2px_2px_0px_0px_rgba(0,0,0,1)]"
              >
                Limpar Concluídas
              </button>
            </div>
          </div>

          <div :if={@show_new_category_form} class="border-[4px] border-black bg-white shadow-[8px_8px_0px_0px_rgba(45,49,66,1)]">
            <form phx-submit="add_category" class="flex flex-col md:flex-row items-stretch">
              <input
                type="text"
                name="category_name"
                placeholder="QUAL O NOME DA NOVA CATEGORIA?"
                class="flex-grow !border-0 !ring-0 !py-4 !px-6 !text-lg !font-bold !bg-transparent placeholder:text-gray-400 uppercase italic"
              />
              <button
                type="submit"
                class="bg-[#2D3142] text-white px-10 py-4 text-lg font-black hover:bg-[#FF5F1F] transition-colors border-t-[4px] md:border-t-0 md:border-l-[4px] border-black uppercase flex items-center justify-center gap-2"
              >
                <span>Adicionar</span>
                <.icon name="hero-plus-solid" class="w-5 h-5 text-[#CFF27E]" />
              </button>
            </form>
          </div>

          <button
            :if={!@show_new_category_form}
            phx-click="toggle_new_category_form"
            class="self-start bg-[#CFF27E] hover:bg-[#FF5F1F] hover:text-white border-2 border-black px-4 py-2 text-sm font-black uppercase transition-all shadow-[3px_3px_0px_0px_rgba(0,0,0,1)]"
          >
            + Nova Categoria
          </button>
        </div>

        <div class="grid gap-4">
          <%= for task <- Enum.filter(@tasks, fn t ->
            case @filter do
              "all" -> true
              "active" -> !t.completed
              "completed" -> t.completed
            end
          end) do %>
            <div class={[
              "group border-[3px] border-black p-5 flex items-center gap-5 transition-all relative",
              task.completed && "bg-gray-50 opacity-60",
              !task.completed &&
                "bg-white shadow-[6px_6px_0px_0px_rgba(0,0,0,1)] hover:shadow-[8px_8px_0px_0px_rgba(207,242,126,1)]"
            ]}>
              <button
                phx-click="toggle_complete"
                phx-value-id={task.id}
                class={[
                  "w-10 h-10 border-[3px] border-black flex items-center justify-center transition-all flex-shrink-0",
                  task.completed && "bg-[#CFF27E]",
                  !task.completed && "bg-white hover:bg-[#FF5F1F]/10"
                ]}
              >
                <.icon :if={task.completed} name="hero-check-badge-solid" class="w-7 h-7" />
              </button>

              <div class="flex-grow">
                <h3 class={[
                  "text-xl font-black uppercase leading-tight",
                  task.completed && "line-through opacity-40"
                ]}>
                  {task.title}
                </h3>
                <div class="flex gap-2 mt-2">
                  <span class={[
                    "text-[9px] font-black px-2 py-0.5 border-2 border-black uppercase shadow-[2px_2px_0px_0px_rgba(0,0,0,1)]",
                    task.priority == "high" && "bg-red-400",
                    task.priority == "medium" && "bg-yellow-300",
                    task.priority == "low" && "bg-blue-300"
                  ]}>
                    <%= case task.priority do %>
                      <% "high" -> %>
                        ALTA
                      <% "medium" -> %>
                        MEDIA
                      <% _ -> %>
                        BAIXA
                    <% end %>
                  </span>
                  <span class="text-[9px] font-black px-2 py-0.5 border-2 border-black uppercase bg-white italic">
                    {task.category || "GERAL"}
                  </span>
                </div>
              </div>

              <button
                phx-click="delete"
                phx-value-id={task.id}
                class="opacity-0 group-hover:opacity-100 bg-[#2D3142] text-white p-2 hover:bg-red-600 transition-all border-2 border-black shadow-[3px_3px_0px_0px_rgba(0,0,0,1)]"
              >
                <.icon name="hero-trash-solid" class="w-4 h-4" />
              </button>
            </div>
          <% end %>

          <div :if={@tasks == []} class="border-[4px] border-dashed border-black/20 p-16 text-center">
            <h4 class="text-3xl font-black uppercase text-black/20 italic mb-2">
              Seu dia está livre
            </h4>
            <p class="text-sm font-bold text-black/40 uppercase">
              Que tal começar algo incrível hoje?
            </p>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
