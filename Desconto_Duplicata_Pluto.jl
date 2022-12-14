### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 60e64723-3721-4bcf-be74-47b80851a880
using DataFrames, DataFramesMeta, XLSX, Chain, Dates, Formatting, Missings,
Markdown, PlutoUI, InteractiveUtils , WebIO, PlutoPlotly #, JSServe

# ╔═╡ 786ba8c1-62ea-4421-9175-9646abb1663a
TableOfContents()

# ╔═╡ 32a827f0-7337-11ed-1fbb-2139538dd547
md"""
# $(html"<p style='font-family:consolas'><b>Style</b></p>")
$(html"<style> main { max-width: 1020px; }")
"""

# ╔═╡ 49fd3e5e-5297-4fd2-8614-2cb4e7fa382a
TableOfContents()

# ╔═╡ fbdd1d81-d305-43b4-b1e0-dd05c0272e98
Local_DB = "C:/Users/danil/OneDrive/Danilo_Back-up/Projetos_Pessoais/Canal_Youtube/Base_Dados"

# ╔═╡ aa89fb9f-8e9a-4994-b2b1-991f98ebd0ee
md""" # $(html"<p style='font-family:consolas'><b>Tabela Base</b></p>")"""

# ╔═╡ 52ffd7f6-a2b5-474a-8814-219dc1832db6
DataFrame( 
	XLSX.readtable( "$(Local_DB)/Ctas_Receber_DB.xlsx",	"Planilha1", infer_eltypes = true )
)

# ╔═╡ 040763ba-346e-44d6-ada2-aed09c232ba9
md""" # $(html"<p style='font-family:consolas'><b>Fórmulas Financeiras</b></p>")"""

# ╔═╡ d67865fe-5b45-4628-a9fb-d1af28ca8c25
md"""
$FV\ =\ Valor\ Futuro$
$PV\ =\ Valor\ Presente$
$i\ =\ Taxa$
$n\ =\ N°\ Períodos$
$Valor\ Futuro:\ \ FV = PV \times (1 + i)^n$
$Valor\ Presente:\ \ PV = \frac{FV}{(1 + i)^n}$
$Taxa:\ \ i = \sqrt[n]{\frac{FV}{PV}} - 1 \ \ ou\ \ \frac{FV}{PV}^\frac{1}{n} - 1$
$N°\ Períodos:\ \ n = \frac{log_{(1+i)}}{log_\frac{FV}{PV}}$
$Valor\ da\ Parcela:\ PMT\ =\ \frac{i}{1-(1-i)^{-n}}$
"""
# $B_1 = b_1 = \frac{\sum{[(X_i - X)(Y_i - Y)]}}{\sum{[(X_i - X)^2]}}$

# ╔═╡ 5019a774-0833-4f5d-996b-9aee6d7e5e8d
md""" # $(html"<p style='font-family:consolas'><b>Tratamento dos Dados</b></p>")"""

# ╔═╡ f7ceb2db-2963-46e7-a972-d3753e10c417
md""" 
$(html"<p style='font-family:consolas'>add Prazo_NF, Prazo_Desc, Prazo_Real, Taxa_Desc, Taxa_Desc * 100, Taxa_Desc formatada<br>Renomear colunas com nomes mais compactos</p>")
"""

# ╔═╡ c2f7eb2b-0cea-4156-b5e6-eb12b5d00c98
F_CTAS_RECEBER =
    @chain DataFrame( XLSX.readtable( "$(Local_DB)/Ctas_Receber_DB.xlsx", "Planilha1", infer_eltypes = true ) ) begin
    select( Not(:ID_Cliente) )
    @transform(
        :Prazo_NF   = Dates.value.( :Data_Vencimento .- :Data_Emissão ),
        :Prazo_Desc = ifelse.(
            :Data_Recebimento .>= :Data_Vencimento,
            missing,
            Dates.value.( :Data_Vencimento .- :Data_Recebimento )
        ),
        :Prazo_Real = Dates.value.( :Data_Recebimento .- :Data_Emissão )
    )
    @transform(
        :Taxa_Desc = ifelse.(
            :Prazo_Desc .=== missing,
            missing,
			let VF = :Valor_a_Receber
				VP = :Valor_Recebido
				n  = :Prazo_Desc ./ 30 # para encontrarmos a taxa em meses
				(VF ./ VP).^(1 ./ n) .- 1 # fórmula da taxa (i)
			end
        )
    )
    @transform( 
        :Taxa_Desc2 = :Taxa_Desc .* 100,
        :Taxa_Desc3 = ifelse.(
            :Taxa_Desc .!== missing,
            string.( round.( :Taxa_Desc .* 100, digits = 2 ), "%" ),
            missing
        )
    )
    rename(
        :Data_Emissão     => :Data_Emi,
        :Data_Vencimento  => :Data_Vecto,
        :Data_Recebimento => :Data_Recto,
        :Valor_a_Receber  => :V_a_Receber,
        :Valor_Recebido   => :V_Recebido,
        :Descontado_com   => :Nome_FDIC
    )
end 

# ╔═╡ e6906ce0-4172-4713-9478-885bd01e7850
PRAZOS_MEDIOS =
    @chain F_CTAS_RECEBER begin
    @transform(
        :Prazo_Desc = coalesce.( :Prazo_Desc, 0 ) # missing => 0
    )
    @transform(
        :Prazo_NF_X_Receber   = Float64.(:Prazo_NF)   .* :V_a_Receber,
        :Prazo_Desc_X_Receber = Float64.(:Prazo_Desc) .* :V_a_Receber,
        :Prazo_Real_X_Receber = Float64.(:Prazo_Real) .* :V_a_Receber
    )
    @combine( # médias ponderadas
        :Prazo_Medio_Orig = sum(:Prazo_NF_X_Receber)   / sum(:V_a_Receber),
        :Prazo_Medio_Desc = sum(:Prazo_Desc_X_Receber) / sum(:V_a_Receber),
        :Prazo_Medio_Real = sum(:Prazo_Real_X_Receber) / sum(:V_a_Receber)
    )
end 

# ╔═╡ dca062f8-f825-4fc0-a9ef-9950ab7e9274
PRAZOS_TAXAS_MEDIOS_DESC =
    @chain F_CTAS_RECEBER begin
    @subset( :Prazo_Desc .> 0 ) # considerar apenas duplicatas descontadas
    @transform(
        :Prazo_NF_X_Receber   = Float64.(:Prazo_NF)   .* :V_a_Receber,
        :Prazo_Desc_X_Receber = Float64.(:Prazo_Desc) .* :V_a_Receber,
        :Prazo_Real_X_Receber = Float64.(:Prazo_Real) .* :V_a_Receber
    )
    @combine(
		:V_a_Receber = Int.(sum(:V_a_Receber)),
		:V_Recebido  = Int.(round.(sum(:V_Recebido), digits = 0)),
        :V_Desconto  = Int.(round.(sum(:Diferenca), digits = 0)),
        :Prazo_Medio_Orig = sum(:Prazo_NF_X_Receber)   / sum(:V_a_Receber),
        :Prazo_Medio_Desc = sum(:Prazo_Desc_X_Receber) / sum(:V_a_Receber),
        :Prazo_Medio_Real = sum(:Prazo_Real_X_Receber) / sum(:V_a_Receber)
    )
    @transform(
        :Taxa_Media_Desc = 
			let PV = :V_Recebido
				FV = :V_a_Receber
				n  = :Prazo_Medio_Desc ./ 30
					(FV ./ PV).^(1 ./ n) .- 1
			end
    )
	@transform(
        :Taxa_Media_Desc2 = string.( sprintf1.("%.2f", :Taxa_Media_Desc .* 100), "%")
    )
end 

# ╔═╡ e498159d-da5f-4049-a803-5629e819544b
md""" # $(html"<p style='font-family:consolas'><b>Análises</b></p>")"""

# ╔═╡ 3392a023-e912-47d1-a146-4bd14d2fa5d1
md"__Seleção de FDIC:__ $( @bind FDIC1 MultiCheckBox( unique(F_CTAS_RECEBER.Nome_FDIC) ) )"

# ╔═╡ 133e3dc3-ba8b-40a8-ab8a-39a9816046a3
md"""
__Group By campos:__ $(@bind GroupBy_1 Select([:Nome_FDIC, :Descr_Cliente, :Ano_Mes_Recto, :Ano_Mes_Emi, missing])) 
$(@bind GroupBy_2 Select([:Nome_FDIC, :Descr_Cliente, :Ano_Mes_Recto, :Ano_Mes_Emi, missing]))
$(@bind GroupBy_3 Select([:Nome_FDIC, :Descr_Cliente, :Ano_Mes_Recto, :Ano_Mes_Emi, missing]))
"""

# ╔═╡ fc1430be-9636-4abb-8006-86e4d7085008
md"""
__Ordenar por:__ $( @bind Ordenar_Por Select( 
	[:Nome_FDIC, :Descr_Cliente, :Ano_Mes_Recto, :Ano_Mes_Emi, :Prazo_Medio_Orig, :Prazo_Medio_Desc, :V_a_Receber, :V_Recebido, :Taxa_Media_Desc, :Taxa_Media_Desc2] 
))
__A_Z:__ $(@bind A_Z Select([true, false]))
"""

# ╔═╡ be99c096-091a-47a0-af81-502aab18d47c
begin
FDIC = ifelse( FDIC1 == [], unique(F_CTAS_RECEBER.Nome_FDIC), FDIC1 )
PRAZOS_MEDIOS_AGREGADOS =
    @chain F_CTAS_RECEBER begin
	@subset( 
		ifelse.(
			length(FDIC) .== 1 .&& FDIC[1] .=== missing,
			:Nome_FDIC .=== missing,
			ifelse.(
				length(FDIC) .== length( collect( skipmissing(FDIC) ) ),
				in.( :Nome_FDIC, Ref(FDIC) ),
				:Nome_FDIC .=== missing .|| in.( :Nome_FDIC, Ref(FDIC) )
			)
		)
	)
    @transform(
        :Prazo_Desc    = coalesce.( :Prazo_Desc, 0 ),
		:Ano_Mes_Recto = SubString.( string.( Date.(:Data_Recto) ), 1, 7),
		:Ano_Mes_Emi   = SubString.( string.( Date.(:Data_Emi) ),   1, 7)
    )
    @transform(
        :Prazo_NF_X_Receber   = :Prazo_NF   .* :V_a_Receber,
        :Prazo_Desc_X_Receber = :Prazo_Desc .* :V_a_Receber,
        :Prazo_Real_X_Receber = :Prazo_Real .* :V_a_Receber
    )
    groupby( 
		unique( skipmissing( [GroupBy_1, GroupBy_2, GroupBy_3] ) )
	)
    @combine(
        :Prazo_Medio_Orig = sum(:Prazo_NF_X_Receber)   / sum(:V_a_Receber),
        :Prazo_Medio_Desc = sum(:Prazo_Desc_X_Receber) / sum(:V_a_Receber),
        # :Prazo_Medio_Real = sum(:Prazo_Real_X_Receber) / sum(:V_a_Receber), 
		:V_a_Receber = round.( sum(:V_a_Receber), digits = 0),
		:V_Recebido  = round.( sum(:V_Recebido),  digits = 0)
    )
    @transform(
        :Taxa_Media_Desc = 
			let FV = :V_a_Receber
				PV = :V_Recebido
				n  = :Prazo_Medio_Desc ./ 30
				(FV ./ PV).^(1 ./ n) .-1
			end
    )
	@transform( 
		:Taxa_Media_Desc2 = string.(round.(:Taxa_Media_Desc .* 100, digits = 2)) .* "%"
	)
	sort( Ordenar_Por, rev = A_Z )
	end
end

# ╔═╡ 6baebd77-f3cc-4f1f-9415-0e660754b88b
md"__Tamanho das Bolhas:__ 
$(@bind Tamanho PlutoUI.Slider(1:0.5:70, default = 1, show_value = true))
"

# ╔═╡ a44077b7-9259-4b71-9f87-682e250e6a15
let F_CTAS_RECEBER = 
	@chain F_CTAS_RECEBER begin
		@subset( :Taxa_Desc .!== missing )
		@subset( :Prazo_Desc .> 9 )
		@transform( 
			:Taxa_Desc3 = :Taxa_Desc2 .* Tamanho
		)
		@transform(
			:Taxa_Desc4 = string.(
				"<b><i>Taxa: ", round.(:Taxa_Desc2, digits = 2), "%", "<br></b></i>", 
				"<b><i>Cliente: ", :Descr_Cliente, "</b></i>"
			)
		)
	end
	plot(
		scatter(
		    F_CTAS_RECEBER,
			x     = :Prazo_Desc,
			y     = :V_a_Receber,
			group = :Nome_FDIC,
		    mode  = "markers",
			text  = :Taxa_Desc4,
		    marker = attr(
				color = :Taxa_Desc,
				size  = :Taxa_Desc3 ,
				# sizeref = maximum(F_CTAS_RECEBER.Taxa_Desc2),
				sizemode = "area"
			)
		)
	)
end

# ╔═╡ 1b0f983f-bdda-48d8-83c0-3c788e4b6d73
let F_CTAS_RECEBER_FDIC1 = 
	@chain F_CTAS_RECEBER begin
		@subset( :Nome_FDIC .== "FDIC_1" )
		@subset( :Prazo_Desc .> 9 )
		@transform( 
			:Taxa_Desc3 = :Taxa_Desc2 .* Tamanho
		)
		@transform(
			:Taxa_Desc4 = string.(
				"<b><i>Taxa: ", round.(:Taxa_Desc2, digits = 2), "%", "<br></b></i>", 
				"<b><i>Cliente: ", :Descr_Cliente, "</b></i>"
			)
		)
	end
	
	F_CTAS_RECEBER_FDIC2 = 
	@chain F_CTAS_RECEBER begin
		@subset( :Nome_FDIC .== "FDIC_2" )
		@subset( :Prazo_Desc .> 9 )
		@transform( 
			:Taxa_Desc3 = :Taxa_Desc2 .* Tamanho
		)
		@transform(
			:Taxa_Desc4 = string.(
				"<b><i>Taxa: ", round.(:Taxa_Desc2, digits = 2), "%", "<br></b></i>", 
				"<b><i>Cliente: ", :Descr_Cliente, "</b></i>"
			)
		)
	end
	
	F_CTAS_RECEBER_FDIC3 = 
	@chain F_CTAS_RECEBER begin
		@subset( :Nome_FDIC .== "FDIC_3" )
		@subset( :Prazo_Desc .> 9 )
		@transform( 
			:Taxa_Desc3 = :Taxa_Desc2 .* Tamanho
		)
		@transform(
			:Taxa_Desc4 = string.(
				"<b><i>Taxa: ", round.(:Taxa_Desc2, digits = 2), "%", "<br></b></i>", 
				"<b><i>Cliente: ", :Descr_Cliente, "</b></i>"
			)
		)
	end
	
	FDIC1 = plot(
			scatter(
			    F_CTAS_RECEBER_FDIC1,
				x     = :Prazo_Desc,
				y     = :V_a_Receber,
				group = :Nome_FDIC,
			    mode  = "markers",
				text  = :Taxa_Desc4,
			    marker = attr(
					color = :Taxa_Desc,
					size = :Taxa_Desc3 ,
					sizemode = "area"
				)
			)
		)
	
	FDIC2 = plot(
			scatter(
			    F_CTAS_RECEBER_FDIC2,
				x     = :Prazo_Desc,
				y     = :V_a_Receber,
				group = :Nome_FDIC,
			    mode  = "markers",
				text  = :Taxa_Desc4,
			    marker = attr(
					color = :Taxa_Desc,
					size = :Taxa_Desc3 ,
					sizemode = "area"
				)
			)
		)
	
	FDIC3 = plot(
			scatter(
			    F_CTAS_RECEBER_FDIC3,
				x     = :Prazo_Desc,
				y     = :V_a_Receber,
				group = :Nome_FDIC,
			    mode  = "markers",
				text  = :Taxa_Desc4,
			    marker = attr(
					color = :Taxa_Desc,
					size = :Taxa_Desc3 ,
					sizemode = "area"
				)
			)
		)
	
	[FDIC1; FDIC2; FDIC3]
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Chain = "8be319e6-bccf-4806-a6f7-6fae938471bc"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
DataFramesMeta = "1313f7d8-7da2-5740-9ea0-a2ca25f37964"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
Formatting = "59287772-0a20-5a39-b81b-1366585eb4c0"
InteractiveUtils = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
Markdown = "d6f4376e-aef5-505a-96c1-9c027394607a"
Missings = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
PlutoPlotly = "8e989ff0-3d88-8e9f-f020-2b208a939ff0"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
WebIO = "0f1e0344-ec1d-5b48-a673-e5cf874b6c29"
XLSX = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"

[compat]
Chain = "~0.5.0"
DataFrames = "~1.4.4"
DataFramesMeta = "~0.12.0"
Formatting = "~0.4.2"
Missings = "~1.0.2"
PlutoPlotly = "~0.3.6"
PlutoUI = "~0.7.49"
WebIO = "~0.8.19"
XLSX = "~0.8.4"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.4"
manifest_format = "2.0"
project_hash = "91f75ff4933ac48a31c9dbd8a672a33107692927"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AssetRegistry]]
deps = ["Distributed", "JSON", "Pidfile", "SHA", "Test"]
git-tree-sha1 = "b25e88db7944f98789130d7b503276bc34bc098e"
uuid = "bf4720bc-e11a-5d0c-854e-bdca1663c893"
version = "0.1.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Chain]]
git-tree-sha1 = "8c4920235f6c561e401dfe569beb8b924adad003"
uuid = "8be319e6-bccf-4806-a6f7-6fae938471bc"
version = "0.5.0"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e7ff6cadf743c098e08fca25c91103ee4303c9bb"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.6"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random", "SnoopPrecompile"]
git-tree-sha1 = "aa3edc8f8dea6cbfa176ee12f7c2fc82f0608ed3"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.20.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "d08c20eef1f2cbc6e60fd3612ac4340b89fea322"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.9"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "00a2cccc7f098ff3b66806862d275ca3db9e6e5a"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.5.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "e08915633fcb3ea83bf9d6126292e5bc5c739922"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.13.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SnoopPrecompile", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "d4f69885afa5e6149d0cab3818491565cf41446d"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.4.4"

[[deps.DataFramesMeta]]
deps = ["Chain", "DataFrames", "MacroTools", "OrderedCollections", "Reexport"]
git-tree-sha1 = "a70c340c1306febfd770a932218561b5e19cf0f6"
uuid = "1313f7d8-7da2-5740-9ea0-a2ca25f37964"
version = "0.12.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "c36550cb29cbe373e95b3f40486b9a4148f89ffd"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.2"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EzXML]]
deps = ["Printf", "XML2_jll"]
git-tree-sha1 = "0fa3b52a04a4e210aeb1626def9c90df3ae65268"
uuid = "8f5d6c58-4d21-5cfd-889c-e3ad7ee6a615"
version = "1.1.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FunctionalCollections]]
deps = ["Test"]
git-tree-sha1 = "04cb9cfaa6ba5311973994fe3496ddec19b6292a"
uuid = "de31a74c-ac4f-5751-b3fd-e18cd04993ca"
version = "0.5.0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.InvertedIndices]]
git-tree-sha1 = "82aec7a3dd64f4d9584659dc0b62ef7db2ef3e19"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.2.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c7cb1f5d892775ba13767a87c7ada0b980ea0a71"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+2"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "946607f84feb96220f480e0422d3484c49c00239"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.19"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Observables]]
git-tree-sha1 = "6862738f9796b3edc1c09d0890afce4eca9e7e93"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.4"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "b64719e8b4504983c7fca6cc9db3ebc8acc2a4d6"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.1"

[[deps.Pidfile]]
deps = ["FileWatching", "Test"]
git-tree-sha1 = "2d8aaf8ee10df53d0dfb9b8ee44ae7c04ced2b03"
uuid = "fa939f87-e72e-5be4-a000-7fc836dbe307"
version = "1.3.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlotlyBase]]
deps = ["ColorSchemes", "Dates", "DelimitedFiles", "DocStringExtensions", "JSON", "LaTeXStrings", "Logging", "Parameters", "Pkg", "REPL", "Requires", "Statistics", "UUIDs"]
git-tree-sha1 = "56baf69781fc5e61607c3e46227ab17f7040ffa2"
uuid = "a03496cd-edff-5a9b-9e67-9cda94a718b5"
version = "0.8.19"

[[deps.PlutoPlotly]]
deps = ["AbstractPlutoDingetjes", "Colors", "Dates", "HypertextLiteral", "InteractiveUtils", "LaTeXStrings", "Markdown", "PlotlyBase", "PlutoUI", "Reexport"]
git-tree-sha1 = "dec81dcd52748ffc59ce3582e709414ff78d947f"
uuid = "8e989ff0-3d88-8e9f-f020-2b208a939ff0"
version = "0.3.6"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eadad7b14cf046de6eb41f13c9275e5aa2711ab6"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.49"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "LaTeXStrings", "Markdown", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "96f6db03ab535bdb901300f88335257b0018689d"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.2"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "a4ada03f999bd01b3a25dcaa30b2d929fe537e00"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.0"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StringManipulation]]
git-tree-sha1 = "46da2434b41f41ac3594ee9816ce5541c6096123"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "c79322d36826aa2f4fd8ecfa96ddb47b174ac78d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "ac00576f90d8a259f2c9d823e91d1de3fd44d348"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WebIO]]
deps = ["AssetRegistry", "Base64", "Distributed", "FunctionalCollections", "JSON", "Logging", "Observables", "Pkg", "Random", "Requires", "Sockets", "UUIDs", "WebSockets", "Widgets"]
git-tree-sha1 = "55ea1b43214edb1f6a228105a219c6e84f1f5533"
uuid = "0f1e0344-ec1d-5b48-a673-e5cf874b6c29"
version = "0.8.19"

[[deps.WebSockets]]
deps = ["Base64", "Dates", "HTTP", "Logging", "Sockets"]
git-tree-sha1 = "f91a602e25fe6b89afc93cf02a4ae18ee9384ce3"
uuid = "104b5d7c-a370-577a-8038-80a2059c5097"
version = "1.5.9"

[[deps.Widgets]]
deps = ["Colors", "Dates", "Observables", "OrderedCollections"]
git-tree-sha1 = "fcdae142c1cfc7d89de2d11e08721d0f2f86c98a"
uuid = "cc8bc4a8-27d6-5769-a93b-9d913e69aa62"
version = "0.6.6"

[[deps.XLSX]]
deps = ["Artifacts", "Dates", "EzXML", "Printf", "Tables", "ZipFile"]
git-tree-sha1 = "ccd1adf7d0b22f762e1058a8d73677e7bd2a7274"
uuid = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"
version = "0.8.4"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "58443b63fb7e465a8a7210828c91c08b92132dff"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.14+0"

[[deps.ZipFile]]
deps = ["Libdl", "Printf", "Zlib_jll"]
git-tree-sha1 = "f492b7fe1698e623024e873244f10d89c95c340a"
uuid = "a5390f91-8eb1-5f08-bee0-b1d1ffed6cea"
version = "0.10.1"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─786ba8c1-62ea-4421-9175-9646abb1663a
# ╠═32a827f0-7337-11ed-1fbb-2139538dd547
# ╠═60e64723-3721-4bcf-be74-47b80851a880
# ╟─49fd3e5e-5297-4fd2-8614-2cb4e7fa382a
# ╟─fbdd1d81-d305-43b4-b1e0-dd05c0272e98
# ╟─aa89fb9f-8e9a-4994-b2b1-991f98ebd0ee
# ╟─52ffd7f6-a2b5-474a-8814-219dc1832db6
# ╟─040763ba-346e-44d6-ada2-aed09c232ba9
# ╠═d67865fe-5b45-4628-a9fb-d1af28ca8c25
# ╟─5019a774-0833-4f5d-996b-9aee6d7e5e8d
# ╟─f7ceb2db-2963-46e7-a972-d3753e10c417
# ╟─c2f7eb2b-0cea-4156-b5e6-eb12b5d00c98
# ╟─e6906ce0-4172-4713-9478-885bd01e7850
# ╟─dca062f8-f825-4fc0-a9ef-9950ab7e9274
# ╟─e498159d-da5f-4049-a803-5629e819544b
# ╟─3392a023-e912-47d1-a146-4bd14d2fa5d1
# ╟─133e3dc3-ba8b-40a8-ab8a-39a9816046a3
# ╟─fc1430be-9636-4abb-8006-86e4d7085008
# ╟─be99c096-091a-47a0-af81-502aab18d47c
# ╟─6baebd77-f3cc-4f1f-9415-0e660754b88b
# ╟─a44077b7-9259-4b71-9f87-682e250e6a15
# ╟─1b0f983f-bdda-48d8-83c0-3c788e4b6d73
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
