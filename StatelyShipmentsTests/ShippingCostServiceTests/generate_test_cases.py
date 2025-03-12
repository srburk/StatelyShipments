#!/usr/bin/env python3
import json
import sys
import os
import heapq
import random

state_border_fee = 50

def load_costs_json(json_file):
    if not os.path.exists(json_file):
        print(f"Error: {json_file} does not exist.", file=sys.stderr)
        sys.exit(1)
    with open(json_file, 'r') as fp:
        costs = json.load(fp)
    return costs

def build_graph(costs):
    graph = {}
    for pair, cost in costs.items():
        state1, state2 = pair.split('-')
        if state1 not in graph:
            graph[state1] = []
        if state2 not in graph:
            graph[state2] = []
        graph[state1].append((state2, cost))
        graph[state2].append((state1, cost))
    return graph

def dijkstra_all(graph, start):
    # Returns a dictionary mapping each node to its minimum cost from start and the corresponding path.
    distances = {node: float('inf') for node in graph}
    distances[start] = 0
    paths = {node: [] for node in graph}
    paths[start] = [start]
    queue = [(0, start)]
    while queue:
        current_cost, node = heapq.heappop(queue)
        if current_cost > distances[node]:
            continue
        for neighbor, weight in graph.get(node, []):
            if weight < 0:
                continue
            new_cost = current_cost + weight + state_border_fee
            if new_cost < distances.get(neighbor, float('inf')):
                distances[neighbor] = new_cost
                paths[neighbor] = paths[node] + [neighbor]
                heapq.heappush(queue, (new_cost, neighbor))
    return distances, paths

def main():
    
    json_file = "graph_weights.json"
    costs = load_costs_json(json_file)
    graph = build_graph(costs)
    
    states = list(graph.keys())
    
    random.seed(42)
    results = []
    num_tests = 100
    
    for i in range(num_tests):
        start, goal = random.sample(states, 2)
        distances, paths = dijkstra_all(graph, start)
        cost = distances.get(goal, float('inf'))
        route = paths.get(goal, []) if cost != float('inf') else None
        test_result = {
            "test_number": i + 1,
            "start": start,
            "goal": goal,
            "cost": cost if cost != float('inf') else None,
            "route": route
        }
        results.append(test_result)
    
    output_file = "expected_results.json"
    with open(output_file, 'w') as fp:
        json.dump(results, fp, indent=2)
    
    print(f"Random test results written to {output_file}")
    
if __name__ == "__main__":
    main()
