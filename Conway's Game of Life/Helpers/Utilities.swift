//
//  Utilities.swift
//  Conway's Game of Life
//
//  Created by Jon Bash on 2020-06-15.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation


@discardableResult
func configure<T>(
   _ value: T,
   with changes: (inout T) throws -> Void
) rethrows -> T {
   var value = value
   try changes(&value)
   return value
}

func undefined<T>(_ message: String = "") -> T {
   fatalError("Undefined: \(message)")
}


extension Optional where Wrapped: Comparable {
   static func < (lhs: Self, rhs: Self) -> Bool {
      guard let lhs = lhs, let rhs = rhs
         else { return false }
      return lhs < rhs
   }
}


extension BinaryFloatingPoint {
   func clamped(to clamp: Self) -> Self {
      (self > clamp) ? clamp : self
   }
}

/*
// MARK: - Linked List

class LinkedList<Element> {
   private var _head: Node<Element>?
   private var _tail: Node<Element>?

   private var head: Element? {
      _head?.value
   }

   func popHead() -> Element? {
      let old = _head
      _head = _head?.next

      if old == _head {
         _tail = nil
      }

      return old?.value
   }

   func addToHead(_ element: Element) {
      _head = Node(element, next: _head)
   }

   func addToTail(_ element: Element) {
      _tail?.next = Node(element)
      _tail = _tail?.next
   }

   private class Node<Value>: Equatable {
      var value: Value
      var next: Node<Value>?

      init(_ value: Value, next: Node<Value>? = nil) {
         self.value = value
         self.next = next
      }

      static func == <T: Equatable>(lhs: LinkedList.Node<T>, rhs: LinkedList.Node<T>) -> Bool {
         lhs.value == rhs.value
      }

      static func == (lhs: LinkedList.Node<Value>, rhs: LinkedList.Node<Value>) -> Bool {
         lhs === rhs
      }
   }
}

// MARK: - Queue

class Queue<Element> {
   private var storage = LinkedList<Element>()

   func enqueue(_ item: Element) {
      storage.addToTail(item)
   }

   func dequeue() -> Element? {
      storage.popHead()
   }
}

// MARK: - Ring Buffer

class RingBuffer<Element> {
   private var storage = [Element]()
   private var index: Int = 0

   init(_ elements: [Element] = []) {
      self.storage = elements
   }

   func add(_ element: Element) {
      storage.append(element)
   }

   func next() -> Element? {
      guard !storage.isEmpty else { return nil }
      if index >= storage.count {
         index %= storage.count
      }
      let element = storage[index]
      index = (index + 1) % storage.count
      return element
   }

   func popLast() -> Element? {
      storage.popLast()
   }
}
*/
