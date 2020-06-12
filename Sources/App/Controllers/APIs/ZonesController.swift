//
//  ZonesController.swift
//  App
//
//  Created by Rujira Petrung on 27/5/20.
//

import Vapor
import Fluent

struct ZonesController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let zonesRoutes = router.grouped("api", "zones")
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = zonesRoutes.grouped(
        tokenAuthMiddleware,guardAuthMiddleware)
        
        tokenAuthGroup.get(use: getAllHandler)
        tokenAuthGroup.post(Zone.self, use: createHandler)
        tokenAuthGroup.get(Zone.parameter, use: getHandler)
        tokenAuthGroup.put(Zone.parameter, use: updateHandler)
        tokenAuthGroup.delete(Zone.parameter, use: deleteHandler)
        tokenAuthGroup.get("search", use: searchHandler)
        tokenAuthGroup.get("first", use: getFirstHandler)
        tokenAuthGroup.get("sorted", use: sortedHandler)
        
    }
    
    //Create (POST)
    func createHandler(_ req: Request, zone: Zone) throws -> Future<Zone> {
        return zone.save(on: req)
    }
    
    //Retrieve All (GET)
    func getAllHandler(_ req: Request) throws -> Future<[Zone]> {
        return Zone.query(on: req).all()
    }
    
    //Get Single (POST)
    func getHandler(_ req: Request) throws -> Future<Zone> {
        return try req.parameters.next(Zone.self)
    }
    
    //Update Single (PUT)
    func updateHandler(_ req: Request) throws -> Future<Zone> {
        return try flatMap(
            to: Zone.self,
            req.parameters.next(Zone.self),
            req.content.decode(Zone.self)
        ) { zone, updatedZone in
            zone.name = updatedZone.name
            zone.zoneType = updatedZone.zoneType
            zone.schoolID = updatedZone.schoolID
            zone.createBy = updatedZone.createBy
            zone.updateBy = updatedZone.updateBy
            return zone.save(on: req)
        }
    }
    
    //Delete Single (DELETE)
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req
            .parameters
            .next(Zone.self)
            .delete(on: req)
            .transform(to: .noContent)
    }
    
    //Search (GET)
    func searchHandler(_ req: Request) throws -> Future<[Zone]> {
        guard let searchTerm = req
            .query[String.self, at: "term"] else {
                throw Abort(.badRequest)
        }
        return Zone.query(on: req).group(.or) { or in
            or.filter(\.name == searchTerm)
        }.all()
    }
    
    //Get First (GET)
    func getFirstHandler(_ req: Request) throws -> Future<Zone> {
        return Zone.query(on: req)
            .first()
            .unwrap(or: Abort(.notFound))
    }
    
    //Sort ascd (GET)
    func sortedHandler(_ req: Request) throws -> Future<[Zone]> {
        return Zone.query(on: req).sort(\.name, .ascending).all()
    }
    
    //Parent-Child Relationships School-Grade
    func getSchoolHandler(_ req: Request) throws -> Future<School> {
        return try req
            .parameters.next(Zone.self)
            .flatMap(to: School.self) { grade in
                grade.school.get(on: req)
        }
    }
    
}
