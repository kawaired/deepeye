using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyCollider : MonoBehaviour
{
    public enum Direction
    {
        X, Y, Z
    }

    public enum ColliderType
    {
        sphere,capsule
    }

    public Vector3 localcenter=Vector3.zero;
    public Direction colliderdir;
    [Range(0,1)]
    public float radius1;
    [Range(0,1)]
    public float radius2;
    [Range(0,10)]
    public float cylinderH;
    private Vector3 centerone;
    private Vector3 centertwo;

    private ColliderType collidertype=ColliderType.sphere;

    //计算碰撞体的中心点
    public void ComputeCenter()
    {
        centerone=localcenter;
        centertwo=localcenter;
        switch (colliderdir)
        {
            case Direction.X:
                centerone.x=localcenter.x+0.5f*cylinderH;
                centertwo.x=localcenter.x-0.5f*cylinderH;
                break;
            case Direction.Y:
                centerone.y=localcenter.y+0.5f*cylinderH;
                centertwo.y=localcenter.y-0.5f*cylinderH;
                break;
            case Direction.Z:
                centerone.z=localcenter.z+0.5f*cylinderH;
                centertwo.z=localcenter.z-0.5f*cylinderH;
                break;
        }
        // Debug.Log(centerone);
        centerone=transform.TransformPoint(centerone);
        centertwo=transform.TransformPoint(centertwo);
    }

    //模拟出碰撞体的形状
    public void DrawCollider()
    {
       ComputeCenter();
        if(cylinderH<=0)
        {
            collidertype=ColliderType.sphere;
        }
        else
        {
            collidertype=ColliderType.capsule;
        }
    }

    //根据骨骼节点位置与半径以及碰撞体自身的属性计算是否会发生碰撞
    public bool CheckCollide(ref Vector3 bonepos,float radius)
    {
        switch(collidertype)
        {
            case ColliderType.sphere:
                return CheckSphere(ref bonepos,radius,centerone,radius1);
            case ColliderType.capsule:
                return CheckCapsule(ref bonepos,radius);
            default:
                return false;
        }
    }

    public float CheckDis(Vector3 a, Vector3 b)
    {
        return (a-b).magnitude;
    }

    //如果发生了碰撞会强制发生位移到不会放生碰撞的位置
    public Vector3 KeepRange(Vector3 pos,Vector3 dir,float colliderange,float dis)
    {
        return pos+dir.normalized*(colliderange-dis);
    }

    //计算投影向量
    public Vector3 ComputeHorizontal(Vector3 projectvector,Vector3 aimvector)
    {
        Vector3 normalhorizontal=projectvector.normalized;
        return Vector3.Dot(aimvector,normalhorizontal)*normalhorizontal;
    }

    //计算向量到投影向量的垂直向量
    public Vector3 ComputeVertical(Vector3 projectvector,Vector3 aimvector)
    {
        Vector3 normalhorizontal=projectvector.normalized;
        return (aimvector-Vector3.Dot(aimvector,normalhorizontal)*normalhorizontal);
    }

    //球形状的碰撞判断
    private bool CheckSphere(ref Vector3 bonepos,float radius,Vector3 colliderpos,float collideradius)
    {
        float dis=CheckDis(bonepos,colliderpos);
        float colliderange=radius+collideradius;
        if(dis>colliderange)
        {
            return false;
        }
        else
        {
            bonepos=KeepRange(bonepos,bonepos-colliderpos,colliderange,dis);
            return true;
        }
    }

    //等宽的圆柱体的碰撞判定
    private bool CheckEqualCylinder(ref Vector3 bonepos,float radius,Vector3 endpoint1,Vector3 endpoint2,float cylinderradius)
    {
        Vector3 onetobone=bonepos-endpoint1;
        Vector3 onegotwo=endpoint2-endpoint1;
        Vector3 verticalvector=ComputeVertical(onegotwo,onetobone);
        float dis=verticalvector.magnitude;
        float colliderange=radius+cylinderradius;
        if(dis>=colliderange)
        {
            return false;
        }
        else
        {
            bonepos=KeepRange(bonepos,verticalvector,colliderange,dis);
            return true;
        }
    }

    public float CheckMin(float a, float b)
    {
        if(a>=b)
        {
            return b;
        }
        else
        {
            return a;
        }
    }

    //不等宽的圆柱体碰撞判定
    public bool CheckInequalCylinder(ref Vector3 bonepos,float radius,Vector3 endpoint1,Vector3 endpoint2,float cylinderradius1,float cylinderradius2)
    {
        Vector3 aimvector=Vector3.zero;
        Vector3 projectionvector=Vector3.zero;
        Vector3 startpos=Vector3.zero;
        if(cylinderradius1<cylinderradius2)
        {
            startpos=endpoint1;

            aimvector=bonepos-endpoint1;
            projectionvector=endpoint2-endpoint1;
        }
        else
        {
            startpos=endpoint2;
            aimvector=bonepos-endpoint2;
            projectionvector=endpoint1-endpoint2;
        }
        Vector3 horizontalvector=ComputeHorizontal(projectionvector,aimvector);
        Vector3 verticalvector=ComputeVertical(projectionvector,aimvector);
        float horizontallong=horizontalvector.magnitude;
        float projectionlong=projectionvector.magnitude;
        float verticallong=verticalvector.magnitude;
        float highreduce=Mathf.Abs(cylinderradius1-cylinderradius2)*(horizontallong/projectionlong);
        float verticalcolliderheigh=highreduce+CheckMin(cylinderradius1,cylinderradius2);
        float factor=highreduce/projectionlong;
        float factor2=Mathf.Sqrt(1+factor*factor);
        Vector3 hfactorvector=verticallong*factor*projectionvector.normalized;
        Vector3 realvertical=verticalvector-hfactorvector;
        Vector3 realhorizontal=horizontalvector+hfactorvector;
        float dis=verticallong-verticalcolliderheigh;
        float colliderange=radius*factor2;
        if(dis>=colliderange)
        {
            return false;
        }
        else
        {
            bonepos=startpos+realhorizontal+(verticalcolliderheigh+colliderange)*factor2*realvertical.normalized;
            return true;
        }
    }

    //骨骼节点与胶囊碰撞体的碰撞判定
    
    private bool CheckCapsule(ref Vector3 bonepos, float radius)
    {
        Vector3 onetobone=bonepos-centerone;
        Vector3 twotobone=bonepos-centertwo;
        Vector3 onegotwo=(centertwo-centerone);
        Vector3 twogoone=(centerone-centertwo);
        bool outone=Vector3.Dot(onegotwo,onetobone)<0;
        bool outtwo=Vector3.Dot(twogoone,twotobone)<0;
        
        //骨骼节点位于胶囊体两边球中心点连成直线的两个端点的外侧时只需要使用球体检测碰撞即可
        if(outone)
        {
           return CheckSphere(ref bonepos,radius,centerone,radius1);
        }
        else if(outtwo)
        {   
            return CheckSphere(ref bonepos,radius,centertwo,radius2);
        }

        //骨骼节点位于胶囊体两边球中心点连成直线的两个端点的内侧时需要使用圆柱体进行碰撞检测
        //如果胶囊体两侧的球半径相等则当做等宽的圆柱进行判断
        if(radius1==radius2)
        {
            return CheckEqualCylinder(ref bonepos,radius,centerone,centertwo,radius1);
        }
        //如果胶囊体两侧的球半径不相等则当做不等宽的圆柱进行判断
        else
        {
            return CheckInequalCylinder(ref bonepos,radius,centerone,centertwo,radius1,radius2);
        }
    }

    void OnDrawGizmos()
    {
        Gizmos.color=Color.green; 
        switch(collidertype)
        {
            case ColliderType.sphere:
                DrawColliderSphere();
                break;
            case ColliderType.capsule:
                DrawColliderCapsule();
                break;
        }
    }

    private void DrawColliderSphere()
    {
        Gizmos.DrawWireSphere(centerone,radius1);
    }

    private void DrawColliderCapsule()
    {
        Gizmos.DrawWireSphere(centerone,radius1);

        Vector3 movex=transform.TransformDirection(new Vector3(1,0,0));
        Vector3 movey=transform.TransformDirection(new Vector3(0,1,0));
        Vector3 movez=transform.TransformDirection(new Vector3(0,0,1));

        if(colliderdir!=Direction.X)
        {
            Gizmos.DrawLine(centerone+movex*radius1,centertwo+movex*radius2);
            Gizmos.DrawLine(centerone-movex*radius1,centertwo-movex*radius2);
        }

        if(colliderdir!=Direction.Y)
        {
            Gizmos.DrawLine(centerone+movey*radius1,centertwo+movey*radius2);
            Gizmos.DrawLine(centerone-movey*radius1,centertwo-movey*radius2);
        }

        if(colliderdir!=Direction.Z)
        {
            Gizmos.DrawLine(centerone+movez*radius1,centertwo+movez*radius2);
            Gizmos.DrawLine(centerone-movez*radius1,centertwo-movez*radius2);
        }

        Gizmos.DrawWireSphere(centertwo,radius2);
    }
}
