package org.nlogo.extensions.nw

import org.nlogo.api.Syntax.AgentsetType
import org.nlogo.api.Syntax.commandSyntax
import org.nlogo.api.Argument
import org.nlogo.api.Context
import org.nlogo.api.DefaultClassManager
import org.nlogo.api.DefaultCommand
import org.nlogo.api.PrimitiveManager
import org.nlogo.extensions.nw.NetworkExtensionUtil.AgentSetToNetLogoAgentSet
import org.nlogo.extensions.nw.NetworkExtensionUtil.AgentSetToRichAgentSet

// TODO: program everything against the API, if possible

class NetworkExtension extends DefaultClassManager
  with HasGraph
  with jung.Primitives
  with jgrapht.Primitives {

  override def load(primManager: PrimitiveManager) {
    val add = primManager.addPrimitive _

    // In original extension:
    add("in-link-radius", InLinkRadius)
    add("in-out-link-radius", InOutLinkRadius)
    add("in-in-link-radius", InInLinkRadius)
    add("mean-link-path-length", MeanLinkPathLength)
    add("link-distance", LinkDistance)
    add("link-path", LinkPath)
    add("link-path-turtles", LinkPathTurtles)
    

    // New:
    add("set-snapshot", SnapshotPrim)

    add("weighted-link-distance", WeightedLinkDistance)
    add("weighted-link-path", WeightedLinkPath)
    add("weighted-link-path-turtles", WeightedLinkPathTurtles)
    add("weighted-mean-link-path-length", WeightedMeanLinkPathLength)

    add("betweenness-centrality", BetweennessCentralityPrim)
    add("eigenvector-centrality", EigenvectorCentralityPrim)
    add("closeness-centrality", ClosenessCentralityPrim)

    add("k-means-clusters", KMeansClusters)
    add("bicomponent-clusters", BicomponentClusters)
    add("weak-component-clusters", WeakComponentClusters)

    add("maximal-cliques", MaximalCliques)
    add("biggest-maximal-clique", BiggestMaximalClique)

    add("generate-preferential-attachment", BarabasiAlbertGeneratorPrim)
    add("generate-random", ErdosRenyiGeneratorPrim)
    add("generate-small-world", KleinbergSmallWorldGeneratorPrim)
    add("generate-lattice-2d", Lattice2DGeneratorPrim)
    add("generate-ring", RingGeneratorPrim)
    add("generate-star", StarGeneratorPrim)
    add("generate-wheel", WheelGeneratorPrim)
    add("generate-wheel-inward", WheelGeneratorInwardPrim)
    add("generate-wheel-outward", WheelGeneratorOutwardPrim)

    add("save-matrix", SaveMatrix)
    add("load-matrix", LoadMatrix)

  }
}

trait HasGraph {
  // TODO: this is a temporary hack. When we modify
  // the core netlogo, we are going to have
  // set-context and with-context primitives,
  // and the static graph is going to be recomputed
  // only if it is dirty
  private var _graph: Option[NetLogoGraph] = None
  def setGraph(g: NetLogoGraph) { _graph = Some(g) }
  def getGraph(context: Context) = _graph match {
    case Some(g: NetLogoGraph) => g
    case _ =>
      val w = context.getAgent.world
      val g = new StaticNetLogoGraph(w.links, w.turtles)
      _graph = Some(g)
      g
  }

  object SnapshotPrim extends DefaultCommand {
    override def getSyntax = commandSyntax(
      Array(AgentsetType, AgentsetType))
    override def perform(args: Array[Argument], context: Context) {
      val turtleSet = args(0).getAgentSet.requireTurtleSet
      val linkSet = args(1).getAgentSet.requireLinkSet
      setGraph(new StaticNetLogoGraph(linkSet, turtleSet))
    }
  }
}