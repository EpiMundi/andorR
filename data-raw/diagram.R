# First, make sure you have the DiagrammeR package installed
# install.packages("DiagrammeR")

# Load the library
library(DiagrammeR)

# Create the diagram using grViz (Graphviz visualization)
grViz("
digraph data_flow {

  #--- Global Graph Attributes ---#
  graph [
    layout = dot,      // Use the 'dot' algorithm for hierarchical layouts
    rankdir = TB,      // Layout direction: Top to Bottom
    splines = ortho,   // Use orthogonal lines for a cleaner look
    overlap = false,   // Prevent nodes from overlapping
    nodesep = 0.8,     // Increase separation between nodes
    ranksep = 1.0,     // Increase separation between ranks/layers
    fontname = 'Helvetica'
  ]

  #--- Global Node Attributes ---#
  node [
    shape = box,
    style = 'filled, rounded',
    fontname = 'Helvetica',
    penwidth = 2
  ]

  #--- Global Edge Attributes ---#
  edge [
    fontname = 'Inconsolata', // A good font for code
    fontsize = 11,
    color = '#555555',
    penwidth = 1.5
  ]


  #--- Layer 1: External File Formats ---#
  subgraph cluster_external {
    label = 'External File Formats';
    style = 'filled';
    bgcolor = '#EBF5FB'; // Light blue background
    fontname = 'Helvetica-Bold';
    fontsize = 16;

    node [fillcolor = '#3498DB', fontcolor = 'white', color = '#2E86C1'];
    csv  [label = 'CSV (Flat File)'];
    yaml [label = 'YAML'];
    json [label = 'JSON'];
  }


  #--- Layer 2: Internal R Representations ---#
  subgraph cluster_internal {
    label = 'Internal R Representations';
    style = 'filled';
    bgcolor = '#E9F7EF'; // Light green background
    fontname = 'Helvetica-Bold';
    fontsize = 16;

    node [fillcolor = '#2ECC71', fontcolor = 'white', color = '#28B463'];
    hier       [label = 'Hierarchical\n(list-of-lists)'];
    path_str   [label = 'Path String\n(vector or data.frame)'];
    relational [label = 'Relational\n(data.frame)'];
  }


  #--- Layer 3: Analysis Format ---#
  subgraph cluster_analysis {
    label = 'Analysis Format';
    style = 'filled';
    bgcolor = '#FEF9E7'; // Light yellow background
    fontname = 'Helvetica-Bold';
    fontsize = 16;

    node [fillcolor = '#F39C12', fontcolor = 'white', color = '#D68910'];
    dt_object [label = 'data.tree Object'];
  }


  #--- Define Edges (Connections) ---#

  # From External to Internal
  # Using 'xlabel' positions the label next to the edge instead of on top of it.
  csv  -> hier       [xlabel = '  load_tree_csv()'];
  csv  -> path_str   [xlabel = '  load_tree_csv_path()'];
  yaml -> relational [xlabel = '  load_tree_yaml()']; # MODIFIED CONNECTION
  json -> relational [xlabel = '  load_tree_json()'];

  # From Internal to Analysis
  hier       -> dt_object [xlabel = '  load_tree_node_list()'];
  path_str   -> dt_object [xlabel = '  load_tree_df_path()'];
  relational -> dt_object [xlabel = '  load_tree_df()'];
}
")
