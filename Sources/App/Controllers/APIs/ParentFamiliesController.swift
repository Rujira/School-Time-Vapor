//
//  ParentFamilyController.swift
//  App
//
//  Created by Rujira Petrung on 29/5/20.
//

import Vapor
import Fluent

struct ParentFamiliesController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let parentFamiliesRoutes = router.grouped("api", "parents")
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = parentFamiliesRoutes.grouped(
        tokenAuthMiddleware,guardAuthMiddleware)
        
        //Generic APIs
        tokenAuthGroup.get(use: getAllHandler)
        tokenAuthGroup.post(ParentFamily.self, use: createHandler)
        tokenAuthGroup.get(ParentFamily.parameter, use: getHandler)
        tokenAuthGroup.put(ParentFamily.parameter, use: updateHandler)
        tokenAuthGroup.delete(ParentFamily.parameter, use: deleteHandler)
        tokenAuthGroup.get("search", use: searchHandler)
        tokenAuthGroup.get("first", use: getFirstHandler)
        tokenAuthGroup.get("sorted", use: sortedHandler)
    }
    
    //Create (POST)
    func createHandler(_ req: Request, parentFamily: ParentFamily) throws -> Future<ParentFamily> {

        return parentFamily.save(on: req)
    }
    
    //Retrieve All (GET)
    func getAllHandler(_ req: Request) throws -> Future<[ParentFamily]> {
        return ParentFamily.query(on: req).all()
    }
    
    //Get Single (POST)
    func getHandler(_ req: Request) throws -> Future<ParentFamily> {
        return try req.parameters.next(ParentFamily.self)
    }
    
    //Update Single (PUT)
    func updateHandler(_ req: Request) throws -> Future<ParentFamily> {
        return try flatMap(
            to: ParentFamily.self,
            req.parameters.next(ParentFamily.self),
            req.content.decode(ParentFamily.self)
        ) { parentFamily, updatedParentFamily in
            parentFamily.fullName = updatedParentFamily.fullName
           
            return parentFamily.save(on: req)
        }
    }
    
    //Delete Single (DELETE)
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req
        .parameters
        .next(ParentFamily.self)
        .delete(on: req)
        .transform(to: .noContent)
    }
    
    //Search (GET)
    func searchHandler(_ req: Request) throws -> Future<[ParentFamily]> {
        guard let searchTerm = req
        .query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return ParentFamily.query(on: req).group(.or) { or in
            or.filter(\.fullName == searchTerm)
        }.all()
    }
    
    //Get First (GET)
    func getFirstHandler(_ req: Request) throws -> Future<ParentFamily> {
        return ParentFamily.query(on: req)
        .first()
        .unwrap(or: Abort(.notFound))
    }
    
    //Sort ascd (GET)
    func sortedHandler(_ req: Request) throws -> Future<[ParentFamily]> {
        return ParentFamily.query(on: req).sort(\.fullName, .ascending).all()
    }

}
